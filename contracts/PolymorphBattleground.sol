//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PolymorphWithGeneChanger.sol";
import "./PolymorphGeneParser.sol";
import "./IUniswapV3Router.sol";
import "./RandomConsumerNumber.sol";

contract PolymorphBattleground is PolymorphGeneParser, RandomNumberConsumer, ReentrancyGuard {
    using SafeMath for uint256;

    address private polymorphsContractAddress;
    address payable public daoAddress;
    address private linkAddress;
    address private wethAddress;
    IUniswapV3Router private uniswapV3Router;
    // TODO:: write docs
    // TODO:: 7. We don’t store records about polymorph wins or loses, all that kind of data will be emitted trough events and captured by the graph.

    struct BattleEntitiy {
        uint256 id;
        uint256 statsMin;
        uint256 statsMax;
        uint256 skillType;
        address owner;
        uint256 wins;
        uint256 loses;
        uint256 lastBattleStats;
    }

    mapping(address => uint256) public playerBalances;
    mapping(uint256 => uint256[]) public battlePools; // roundId => [22,23] polymorphs ids
    mapping(uint256 => mapping(uint256 => BattleEntitiy)) public entities; // battlePoolIndex => polymorphId => BattleEntity
    uint256 private enterFee = 0.1 ether;
    uint256 public daoFeeBps = 1000; // to be configurable
    uint256 public operationalFeeBps = 1000; // to be configurable
    uint256 public rngChainlinkCost = 100000000000000000; // to be configurable
    uint256 public roundIndex; // Round index to be executed
    uint256 public battlePoolIndex; // Current battle pool index to insert entities into
    uint256 private maxPoolSize = 40;
    bool public inRound; // If the execution of a round has begun

    event LogBattleEntered(
        uint256 polymorphId,
        uint256 skillType,
        address owner,
        uint256 time
    );

    event LogRoundExecuted(
        uint256 roundIndex,
        uint256 time
    );

    event LogPolymorphsBattled(
        uint256 firstPolymorphId,
        uint256 firstPolymorphStats,
        uint256 secondPolymorphId,
        uint256 secondPolymorphStats,
        address winner,
        uint256 time
    );

    event LogLinkExchanged(
        uint256 amount,
        uint256 time,
        address initiator
    );

    event LogRewardsClaimed(
        uint256 amount,
        address claimer
    );

    modifier onlyDAO() {
        require(msg.sender == daoAddress, "Not called from the dao");
        _;
    }

    constructor(address _polymorphContractAddress, address payable _daoAddress, address _uniswapV3Router, address _linkAddress, address _wethAddress) {
        //TODO:: Add events
        polymorphsContractAddress = _polymorphContractAddress;
        daoAddress = _daoAddress;
        linkAddress = _linkAddress;
        wethAddress = _wethAddress;
        uniswapV3Router = IUniswapV3Router(_uniswapV3Router);
    }

    /// @notice The user enters a battle. The function checks whether the user is owner of the morph. Also the wager is sent to the contract and the user's morph enters the pool.
    /// @param polymorphId Id of the polymorph
    /// @param skillType Attack or Defence
    function enterBattle(uint256 polymorphId, uint256 skillType)
        external
        payable
    {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        require(polymorphsContract.ownerOf(polymorphId) == msg.sender, "You must be the owner of the polymorph");
        require(msg.value >= enterFee, "The sended fee is not enough !");

        // Handle owner already registered for the battlePoolIndex
        require(entities[battlePoolIndex][polymorphId].id == 0, "You have already registered for the current battle pool");

        // Deducts the required fees and registers the wager balance to the player
        uint256 wagerAfterfees = _getWagerAfterFees(msg.value);
        // Increment the player balance with the wager amount (after fees being deducted)
        playerBalances[msg.sender] = playerBalances[msg.sender].add(wagerAfterfees);

        // Handle pool overflow by increasing the current battlePoolIndex so we can start fulfilling the next pool
        // Handle started pool fight with left open slots, fullfil the next pool
        if (
            battlePools[battlePoolIndex].length == maxPoolSize ||
            inRound && battlePoolIndex == roundIndex
            ) battlePoolIndex = battlePoolIndex + 1;

        (uint256 min, uint256 max) = getStatsPoints(polymorphId, skillType);

        // Create or update an entity in the polymorphs mapping
        BattleEntitiy memory entitiy = BattleEntitiy({
            id: polymorphId,
            statsMin: min,
            statsMax: max,
            skillType: skillType,
            owner: msg.sender,
            wins: 0,
            loses: 0,
            lastBattleStats: 0
        });

        // Insert into the userEntities => for that pool index the user will fight with this polymoprh
        entities[battlePoolIndex][polymorphId] = entitiy;

        // 6. Enter the battlePools with the polymorphId
        battlePools[battlePoolIndex].push(polymorphId);

        emit LogBattleEntered(
            polymorphId,
            skillType,
            entitiy.owner,
            block.timestamp
        );
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will pull two random polymorphs from the battle pool using the Chainlink VRF
    /// @param ethAmount ETH amount which will be used to swap for LINK
    function executeRound(uint256 ethAmount) external {
        require(!lockExecuteRound, "Round execution has been locked !");
        lockExecuteRound = true;

        IERC20 chainlinkToken = IERC20(linkAddress);
        uint256 chainlinkBalance = chainlinkToken.balanceOf(address(this));
        
        // Check if there is enough LINK and if not, call Uniswap to swap ETH for LINK
        if (chainlinkBalance < rngChainlinkCost) {
            getLinkForRNGCosts(rngChainlinkCost, ethAmount);
        }

        getRandomNumber();
    }

    /// @notice Calculates the attack score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getStatsPoints(uint256 polymorphId, uint256 skillType) private view returns (uint256 min, uint256 max) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate stats points for no Gene");
        return getStats(gene, skillType);
    }

    /// @notice The actual battle calculation where the comparison happens
    function battlePolymorphs()
        public
    {
        require(battlePools[roundIndex].length >= 2, "Not enough polymorphs into the Battle Pool !");
        require(randomResult != 0 && lockExecuteRound, "Random result is 0");

        // Indicate that a round has started, so no new entries cant be accepted in the fight pool
        inRound = true;

        while(battlePools[roundIndex].length >= 2) {
            // Take random numbers for picking opponents
            uint256[] memory randoms = expand(randomResult, 2);

            // Take a random index between 0 and the current pool range
            uint256 first = randoms[0] % (battlePools[roundIndex].length - 1);
            uint256 firstId = battlePools[roundIndex][first];
            BattleEntitiy storage entitiy = entities[roundIndex][firstId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(first);

            // Take second random number from the range
            uint256 second;
            if (battlePools[roundIndex].length - 1 < 1) second = randoms[1] % 1; // if the length is 1 we should take 1 otherwise number % 0 = NaN
            else second = randoms[1] % (battlePools[roundIndex].length - 1);
            uint256 secondId = battlePools[roundIndex][second];
            BattleEntitiy storage entitiy2 = entities[roundIndex][secondId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(second);

            // Take random numbers for stats calculations
            uint256[] memory statsRandoms = expand(randoms[1], 2);

            // Calculate stats
            uint256 statsFirst = entitiy.statsMin + (statsRandoms[0] % (entitiy.statsMax - entitiy.statsMin));
            uint256 statsSecond = entitiy2.statsMin + (statsRandoms[1] % (entitiy2.statsMax - entitiy2.statsMin));

            // winner
            address winner;
            address loser;
            if (statsFirst > statsSecond) {
                entitiy.wins = entitiy.wins + 1;
                entitiy2.loses = entitiy2.loses + 1;
                winner = entitiy.owner;
                loser = entitiy2.owner;
            }

            if (statsSecond > statsFirst) {
                entitiy.loses = entitiy.loses + 1;
                entitiy2.wins = entitiy2.wins + 1;
                winner = entitiy2.owner;
                loser = entitiy.owner;
            }

            // Equal stats case, select the winner based on the random numbers used for forming the stats
            if (statsFirst == statsSecond) {
                if (statsRandoms[0] > statsRandoms[1]) {
                    entitiy.wins = entitiy.wins + 1;
                    entitiy2.loses = entitiy2.loses + 1;
                    winner = entitiy.owner;
                    loser = entitiy2.owner;
                } else {
                    entitiy.loses = entitiy.loses + 1;
                    entitiy2.wins = entitiy2.wins + 1;
                    winner = entitiy2.owner;
                    loser = entitiy.owner;
                }
            }

            // Calculate the wager after fees and add it to the winner, substract it from the loser
            uint256 wagerAfterfees = _getWagerAfterFees(enterFee);
            playerBalances[winner] = playerBalances[winner].add(wagerAfterfees);
            playerBalances[loser] = playerBalances[loser].sub(wagerAfterfees);

            // // Save last stats points
            entitiy.lastBattleStats = statsFirst;
            entitiy2.lastBattleStats = statsSecond;

            emit LogPolymorphsBattled(
                entitiy.id,
                entitiy.lastBattleStats,
                entitiy2.id,
                entitiy2.lastBattleStats,
                winner,
                block.timestamp
                );

            // Update the last random result for that pool fight, so we will have a new one in the next cycle
            randomResult = statsRandoms[1];
        }

        // Handle the case if the roundIndex == battlePoolIndex (this means that the battle is over and nobody has entered for new battles
        // in order to create the next pool we have to increase the battlePoolIndex)
        if (battlePoolIndex == roundIndex) {
            battlePoolIndex = battlePoolIndex + 1;
        }

        // Handle the case if we have odd number of participants
        if (battlePools[roundIndex].length == 1) {

            uint256 newEntityId = battlePools[roundIndex][0];

            // Pop the last remaining id
            battlePools[roundIndex].pop();

            // Copy the entity into the entities for the next pool
            BattleEntitiy memory newEntity = entities[roundIndex][newEntityId];
            // Check if the id is not already persistant in the next pool (this could happen if the user sells his polymoprh
            // And the new owner enters the battle in that pool)
            // In that case insert him in the next one, even if battlePoolIndex has not reached the index
            if (entities[battlePoolIndex][newEntityId].id == 0) {
                entities[battlePoolIndex][newEntityId] = newEntity;
                battlePools[battlePoolIndex].push(newEntityId);
                // Push the polymoph id into the new active pool
            } else {
                entities[battlePoolIndex + 1][newEntityId] = newEntity;
                battlePools[battlePoolIndex + 1].push(newEntityId);
            }

        }

        // Reset randomResult
        randomResult = 0;

        // Allow executeRound
        lockExecuteRound = false;

        // Increase the round index
        emit LogRoundExecuted(roundIndex, block.timestamp);
        roundIndex = roundIndex + 1;

        // Indicate that the fight round has finished
        inRound = false;
    }

    /// @notice Moves battle entity to the end of the pool and pops it out
    function swapAndPopEntity(uint256 polymoprhIndex) private {
        // If its not already the last element
        if (polymoprhIndex != battlePools[roundIndex].length - 1) {
            uint256 temp = battlePools[roundIndex][battlePools[roundIndex].length - 1];
            uint256 curr = battlePools[roundIndex][polymoprhIndex];
            // Move the current to the end
            battlePools[roundIndex][battlePools[roundIndex].length - 1] = curr;
            // Put the last one on the current place
            battlePools[roundIndex][polymoprhIndex] = temp;
        }
        // Remove the element
        battlePools[roundIndex].pop();
    }

    /// @notice converts it to LINK, so costs can be coverd for RNG generation
    /// @param linkAmount Exact LINK(Chainlink) amount to swap
    /// @param ethAmount ETH amount to swap for link - difference is refunded
    function getLinkForRNGCosts(uint256 linkAmount, uint256 ethAmount) internal nonReentrant {
        require(ethAmount > 0, "Must pass non 0 ETH amount");
        require(linkAmount > 0, "Must pass non 0 LINK amount");

        uint256 deadline = block.timestamp + 60;
        address tokenIn = wethAddress;
        address tokenOut = linkAddress;
        uint24 fee = 3000;
        address recipient = address(this);
        uint256 amountOut = linkAmount;
        uint256 amountInMaximum = ethAmount;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            amountOut,
            amountInMaximum,
            sqrtPriceLimitX96
        );

        uniswapV3Router.exactOutputSingle{ value: ethAmount }(params);
        // refund leftover ETH to user
        uniswapV3Router.refundETH();

        emit LogLinkExchanged(linkAmount, block.timestamp, msg.sender);
    }

    /// @notice Updates the player balance reward after finished battle
    /// @param player - The address of the player
    function upadteRewardBalance(address player) internal {
        // TODO :: update the playerBalances mapping
    }

    /// @notice Claims the available balance of player
    function claimRewards() external nonReentrant {
        address payable recipient = payable(msg.sender);
        require(playerBalances[msg.sender] > 0, "Balance is zero");

        uint256 ethTransferAmount = playerBalances[msg.sender];
        playerBalances[msg.sender] = 0;
        (bool success, ) = recipient.call{value: ethTransferAmount}("");
        require(success, "Transfer failed");

        emit LogRewardsClaimed(ethTransferAmount, msg.sender);
    }

    function _getWagerAfterFees(uint256 wagerAmount)
    internal
    view
    returns(uint256)
    {
        uint256 daoFee = _calculateDAOfee(wagerAmount, daoFeeBps);
        uint256 operationalFee = _calculateOperationalFees(wagerAmount, operationalFeeBps);
        uint256 wagerAfterfees = wagerAmount.sub(daoFee).sub(operationalFee);
        return wagerAfterfees;
    }

    /// @notice Subtracts predefined fee which will be used for covering fees for calling executeRound() and getting LINK for random number generation.
    function _calculateOperationalFees(uint256 _wagerAmount, uint256 _operationalFeeBps) internal pure returns (uint256) {
        return _operationalFeeBps.mul(_wagerAmount).div(10000);
    }

    /// @notice Subtracts predefined DAO fee in BPS and sends it to the DAO/Treasury
    function _calculateDAOfee(uint256 _wagerAmount, uint256 _daoFeeBps) internal pure returns (uint256) {
        return _daoFeeBps.mul(_wagerAmount).div(10000);
    }

    receive() external payable {}
}
