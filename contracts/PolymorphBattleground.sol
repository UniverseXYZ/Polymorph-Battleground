//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PolymorphWithGeneChanger.sol";
import "./BattleStatsCalculator.sol";
import "./IUniswapV3Router.sol";
import "./RandomConsumerNumber.sol";

contract PolymorphBattleground is BattleStatsCalculator, RandomNumberConsumer, ReentrancyGuard {
    using SafeMath for uint256;

    address private polymorphsContractAddress;
    address payable public daoAddress;
    address private linkAddress;
    address private wethAddress;
    IUniswapV3Router private uniswapV3Router;

    struct BattleEntity {
        uint256 id;
        uint256 statsMin;
        uint256 statsMax;
        uint256 skillType;
        address owner;
    }

    bool public inRound; // If the execution of a round has begun
    uint256 public roundIndex; // The round be executed
    uint256 public battlePoolIndex; // Current battlePoolIndex to insert entities
    uint256 public daoFeeBps;
    uint256 public operationalFeeBps;
    uint256 public rngChainlinkCost;
    uint256 private maxPoolSize = 40;
    uint256 private wager;
    uint256 private randomNumber;

    mapping(address => uint256) public playerBalances;
    mapping(uint256 => mapping(uint256 => BattleEntity)) public entities; //battlePoolIndex => polymorphId => BattleEntity
    mapping(uint256 => uint256[]) public battlePools; // battlePoolIndex => [22,23] polymorphs ids

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

    constructor(
        address _polymorphContractAddress,
        address payable _daoAddress,
        address _uniswapV3Router,
        address _linkAddress,
        address _wethAddress,
        uint256 _daoFeeBps,
        uint256 _operationalFeeBps,
        uint256 _rngChainlinkCost,
        uint256 _wager
        )
    {
        polymorphsContractAddress = _polymorphContractAddress;
        daoAddress = _daoAddress;
        linkAddress = _linkAddress;
        wethAddress = _wethAddress;
        uniswapV3Router = IUniswapV3Router(_uniswapV3Router);
        daoFeeBps = _daoFeeBps;
        operationalFeeBps = _operationalFeeBps;
        rngChainlinkCost = _rngChainlinkCost;
        wager = _wager;
    }

    /// @notice The user enters a battle. The function checks whether the user is owner of the morph. Also the wager is sent to the contract and the user's morph enters the desired wager pool.
    /// @param polymorphId Id of the polymorph
    /// @param skillType Attack or Defence
    function enterBattle(uint256 polymorphId, uint256 skillType)
        external
        payable
    {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        require(polymorphsContract.ownerOf(polymorphId) == msg.sender, "You must be the owner of the polymorph");

        // Handle owner already registered for the battlePoolIndex
        BattleEntity storage entity = entities[battlePoolIndex][polymorphId];
        require(entity.id == 0, "You have already registered for the current battle pool");

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

        // Update the entity
        entity.id = polymorphId;
        entity.statsMin = min;
        entity.statsMax = max;
        entity.skillType = skillType;
        entity.owner = msg.sender;

        // 6. Enter the battlePools with the polymorphId
        battlePools[battlePoolIndex].push(polymorphId);

        emit LogBattleEntered(
            polymorphId,
            skillType,
            entity.owner,
            block.timestamp
        );
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will make request for a random number using the Chainlink VRF
    /// @param ethAmount ETH amount which will be used to swap for LINK
    function executeRound(uint256 ethAmount) external {
        IERC20 chainlinkToken = IERC20(linkAddress);
        uint256 chainlinkBalance = chainlinkToken.balanceOf(address(this));

        // Check if there is enough LINK and if not, call Uniswap to swap ETH for LINK
        if (chainlinkBalance < rngChainlinkCost) {
            getLinkForRNGCosts(rngChainlinkCost, ethAmount);
        }

        getRandomNumber();
    }

    /// @notice Calculates the stats score range of the polymorph based on its gene for example (50 - 75)
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
        uint256[] storage battlePool = battlePools[roundIndex];
        require(battlePool.length >= 2, "Not enough polymorphs into the Wager Battle Pool !");
        require(randomNumber != 0, "Random result is 0, please request a random number !");

        // Indicate that a round has started, so no new entries cant be accepted in the fight pool
        inRound = true;

        while(battlePool.length >= 2) {
            // Take random numbers for picking opponents
            uint256[] memory randoms = expand(randomNumber, 2);

            // Take a random index between 0 and the current pool range
            uint256 first = randoms[0] % (battlePool.length - 1);
            uint256 firstId = battlePool[first];
            BattleEntity storage entity = entities[battlePoolIndex][firstId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(first);

            // Take second random number from the range
            // if the length is 1 we should take 1 otherwise number % 0 = NaN
            uint256 second = (battlePool.length - 1 < 1) ? randoms[1] % 1 : randoms[1] % (battlePool.length - 1);
            uint256 secondId = battlePool[second];
            BattleEntity storage entity2 = entities[battlePoolIndex][secondId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(second);

            // Take random numbers for stats calculations
            uint256[] memory statsRandoms = expand(randoms[1], 2);

            // Calculate stats
            uint256 statsFirst = entity.statsMin + (statsRandoms[0] % (entity.statsMax - entity.statsMin));
            uint256 statsSecond = entity2.statsMin + (statsRandoms[1] % (entity2.statsMax - entity2.statsMin));

            // winner
            address winner;
            address loser;
            if (statsFirst > statsSecond) {
                winner = entity.owner;
                loser = entity2.owner;
            }

            if (statsSecond > statsFirst) {
                winner = entity2.owner;
                loser = entity.owner;
            }

            // Equal stats case, select the winner based on the random numbers used for forming the stats
            if (statsFirst == statsSecond) {
                if (statsRandoms[0] > statsRandoms[1]) {
                    winner = entity.owner;
                    loser = entity2.owner;
                } else {
                    winner = entity2.owner;
                    loser = entity.owner;
                }
            }

            // Calculate the wager after fees (based on the wager pool) and add it to the winner, substract it from the loser
            uint256 wagerAfterfees = _getWagerAfterFees(wager);
            playerBalances[winner] = playerBalances[winner].add(wagerAfterfees);
            playerBalances[loser] = playerBalances[loser].sub(wagerAfterfees);

            emit LogPolymorphsBattled(
                entity.id,
                statsFirst,
                entity2.id,
                statsSecond,
                winner,
                block.timestamp
                );

            // Update the last random result for that pool fight, so we will have a new one in the next cycle
            randomNumber = statsRandoms[1];
        }

        // Handle the case if the roundIndex == battlePoolIndex (this means that the battle is over and nobody has entered for new battles
        // in order to create the next pool we have to increase the battlePoolIndex)
        if (battlePoolIndex == roundIndex) {
            battlePoolIndex = battlePoolIndex + 1;
        }

        // Handle the case if we have odd number of participants
        if (battlePool.length == 1) {

            uint256 newEntityId = battlePool[0];

            // Pop the last remaining id
            battlePool.pop();

            // Copy the entity into the entities for the next pool
            BattleEntity memory newEntity = entities[roundIndex][newEntityId];
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

        // Reset randomNumber for that wager pool
        randomNumber = 0;

        // Increase the round index
        emit LogRoundExecuted(roundIndex, block.timestamp);
        roundIndex = roundIndex + 1;

        // Indicate that the fight round has finished
        inRound = false;
    }

    /// @notice Moves battle entity to the end of the pool and pops it out
    function swapAndPopEntity(uint256 polymoprhIndex) private {
        uint256[] storage battlePool = battlePools[roundIndex];

        // If its not already the last element
        if (polymoprhIndex != battlePool.length - 1) {
            uint256 last = battlePool[battlePool.length - 1];
            uint256 curr = battlePool[polymoprhIndex];
            // Move the current to the end
            battlePool[battlePool.length - 1] = curr;
            // Put the last one on the current place
            battlePool[polymoprhIndex] = last;
        }
        // Remove the element
        battlePool.pop();
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

    /// @notice Calculates the wager after deducted fees
    /// @param wagerAmount the amount of wager to calculate for
    /// @return the wager after the fees deduction
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

    ///@notice this is a Callback method which is getting called in RandomConsumerNumber.sol
    function saveRandomNumber(uint256 n) internal override {
        randomNumber = n;
    }

    receive() external payable {}
}
