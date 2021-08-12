//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PolymorphWithGeneChanger.sol";
import "./BattleStatsCalculator.sol";
import "./RandomConsumerNumber.sol";
import "./FeesCalculator.sol";
import "./FundLink.sol";

contract PolymorphBattleground is BattleStatsCalculator, FeesCalculator, RandomNumberConsumer, ReentrancyGuard, FundLink {
    using SafeMath for uint256;

    address private polymorphsContractAddress;
    address payable private daoAddress;

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
    uint256 public maxPoolSize = 40;
    uint256 public minPoolSize = 10; // There should be enough participants, in order to incentivise the callers of start/finish round methods
    uint256 public wager = 100000000000000000; // 0,1
    uint256 public randomNumber;
    uint256 public roundFees;
    uint256 public paidEthAmountForLinkSwap;
    uint256 public startRoundIncetive;
    uint256 public finishRoundIncetive;

    mapping(address => uint256) public playerBalances;
    mapping(uint256 => mapping(uint256 => BattleEntity)) public entities; //battlePoolIndex => polymorphId => BattleEntity
    mapping(uint256 => uint256[]) public battlePools; // battlePoolIndex => [22,23] polymorphs ids
    mapping(address => uint256) public participatedBattlePoolIndex;

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
        uint256 _startRoundIncetive,
        uint256 _finishRoundIncetive,
        address _vrfCoordinator
        )
        FeesCalculator(_daoFeeBps, _operationalFeeBps)
        FundLink(_uniswapV3Router, _linkAddress, _wethAddress, _rngChainlinkCost)
        RandomNumberConsumer(_vrfCoordinator)
    {
        polymorphsContractAddress = _polymorphContractAddress;
        daoAddress = _daoAddress;
        startRoundIncetive = _startRoundIncetive;
        finishRoundIncetive = _finishRoundIncetive;
    }

    /// @notice The user enters a battle. The function checks whether the user is owner of the morph. Also the wager is sent to the contract and the user's morph enters the pool.
    /// @param polymorphId Id of the polymorph
    /// @param skillType Attack or Defence
    function enterBattle(uint256 polymorphId, uint256 skillType) external payable nonReentrant {
        require(msg.value >= wager, "Not enough ETH amount sent to enter the pool !");
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        require(polymorphsContract.ownerOf(polymorphId) == msg.sender, "You must be the owner of the polymorph");

        // Handle owner already registered for the battlePoolIndex
        require(entities[battlePoolIndex][polymorphId].id == 0, "You have already registered for the current battle pool");

        // Increment the player balance with the wager amount, the fees will be deducted after battle
        playerBalances[msg.sender] = playerBalances[msg.sender].add(msg.value);

        // Refund overpaid amount
        if (msg.value > wager) {
            address payable recipient = payable(msg.sender);
            uint256 overpaidAmount = msg.value.sub(wager);
            playerBalances[msg.sender] = playerBalances[msg.sender].sub(overpaidAmount);
            (bool success, ) = recipient.call{value: overpaidAmount}("");
            require(success, "Refund failed");
        }

        // Handle pool overflow by increasing the current battlePoolIndex so we can start fulfilling the next pool
        // Handle started pool fight with left open slots, fullfil the next pool
        // Handle random number requested for the current pool (fees have already been calculated), fullfil the next pool
        if (
            battlePools[battlePoolIndex].length == maxPoolSize ||
            inRound && battlePoolIndex == roundIndex
            ) battlePoolIndex++;

        BattleEntity storage entity = entities[battlePoolIndex][polymorphId];

        (uint256 min, uint256 max) = getStatsPoints(polymorphId, skillType);

        // Update the entity
        entity.id = polymorphId;
        entity.statsMin = min;
        entity.statsMax = max;
        entity.skillType = skillType;
        entity.owner = msg.sender;

        // Enter the battlePools with the polymorphId
        battlePools[battlePoolIndex].push(polymorphId);

        // Cache participated battlePoolIndex
        participatedBattlePoolIndex[msg.sender] = battlePoolIndex;

        emit LogBattleEntered(
            polymorphId,
            skillType,
            entity.owner,
            block.timestamp
        );
    }

    /// @notice Calculates the stats score range of the polymorph based on its gene for example (50 - 75)
    /// @param polymorphId Id of the polymorph
    function getStatsPoints(uint256 polymorphId, uint256 skillType) private view returns (uint256 min, uint256 max) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate stats points for no Gene");
        return getStats(gene, skillType);
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will make request for a random number using the Chainlink VRF
    function startRound() external {
        require(!inRound, "A round has already started, wait for it to finish !");
        require(battlePools[roundIndex].length >= minPoolSize, "Not enough polymorphs into the Battle Pool !");

        // Indicate that a round has started, so no new entries cant be accepted in the current (roundIndex) fight pool
        // Also the fees for that roindIndex will be calculated
        inRound = true;

        // Calls Uniswap to swap ETH for LINK
        getLinkForRNGCosts();

        // Set the fees for the current round, based on the participants count and the paid ethAmount for LINK
        roundFees = getFeesAmount(
            wager,
            paidEthAmountForLinkSwap,
            battlePools[roundIndex].length,
            startRoundIncetive,
            finishRoundIncetive
            );

        // Makes the actual call for random number
        getRandomNumber();

        // return Incentive fee per polymorph (DAO configurable) to the function caller
        uint256 callerIncetiveAmount = calculateIncetivise(startRoundIncetive, battlePools[roundIndex].length);

        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: callerIncetiveAmount}("");
        require(success, "Start round incetinve failed");
    }

    /// @notice The actual battle calculation where the comparison happens
    function finishRound() public {
        uint256[] storage battlePool = battlePools[roundIndex];
        require(battlePool.length >= minPoolSize, "Not enough polymorphs into the Battle Pool !");
        require(randomNumber != 0, "Random Number is 0, please request a random number or wait for its fulfilment !");
        require(roundFees * battlePools[roundIndex].length <= address(this).balance, "Not enough ETH in contract to pay Fees, the wager must be bigger or decrase the incentives !");

        uint256 participants = battlePool.length;

        while(battlePool.length >= 2) {
            // Take random numbers for picking opponents
            uint256[] memory randoms = expand(randomNumber, 2);

            // Take a random index between 0 and the current pool range
            uint256 first = randoms[0] % battlePool.length;
            uint256 firstId = battlePool[first];
            BattleEntity storage entity = entities[battlePoolIndex][firstId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(first);

            // Take second random number from the range
            // if the length is 1 we should take 1 otherwise number % 0 = NaN
            uint256 second = (battlePool.length - 1 < 1) ? 0 : randoms[1] % battlePool.length;
            uint256 secondId = battlePool[second];
            BattleEntity storage entity2 = entities[battlePoolIndex][secondId];

            // Move the polymorph to the end of the array and pop it
            swapAndPopEntity(second);

            // Take random numbers for stats calculations
            uint256[] memory statsRandoms = expand(randoms[1], 2);

            // Calculate stats
            uint256 statsFirst = entity.statsMin + (statsRandoms[0] % (1 + (entity.statsMax - entity.statsMin)));
            uint256 statsSecond = entity2.statsMin + (statsRandoms[1] % (1 + (entity2.statsMax - entity2.statsMin)));

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

            // Substract the fees for participation in the game
            playerBalances[winner] = playerBalances[winner].sub(roundFees);
            playerBalances[loser] = playerBalances[loser].sub(roundFees);
            // Add the won wager to the winner, and substract it from the loser
            uint256 wagerAfterfees = wager.sub(roundFees);
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

                // Cache participated battlePoolIndex
                participatedBattlePoolIndex[msg.sender] = battlePoolIndex;
            } else {
                entities[battlePoolIndex + 1][newEntityId] = newEntity;
                battlePools[battlePoolIndex + 1].push(newEntityId);

                // Cache participated battlePoolIndex
                participatedBattlePoolIndex[msg.sender] = battlePoolIndex + 1;
            }
        }

        // Reset randomNumber for that round
        randomNumber = 0;

        // Increase the round index
        emit LogRoundExecuted(roundIndex, block.timestamp);
        roundIndex = roundIndex + 1;

        // Indicate that the fight round has finished
        inRound = false;

        // Reset roundFees
        roundFees = 0;

        // Reset paid ETH for Link amount
        paidEthAmountForLinkSwap = 0;

        // Incetivise function caller included into the enter fees
        uint256 activePlayers = participants % 2 == 0 ? participants : participants - 1;
        uint256 callerIncetiveAmount = calculateIncetivise(finishRoundIncetive, activePlayers);

        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: callerIncetiveAmount}("");
        require(success, "Fnish round incetinve failed");
    }

    /// @notice Moves battle entity to the end of the pool and pops it out
    function swapAndPopEntity(uint256 polymoprhIndex) public {
        uint256[] storage battlePool = battlePools[roundIndex];

        // If its not already the last element
        if (polymoprhIndex != battlePool.length - 1) {
            uint256 last = battlePool[battlePool.length - 1];
            // Put the last one on the current place
            battlePool[polymoprhIndex] = last;
        }
        // Remove the element
        battlePool.pop();
    }

    /// @notice Claims the available balance of player
    function claimRewards() external nonReentrant {
        require(participatedBattlePoolIndex[msg.sender] < roundIndex, "You have joined pool which is still in execution or has not been started yet !");
        require(playerBalances[msg.sender] > 0, "Balance is zero");

        address payable recipient = payable(msg.sender);
        uint256 ethTransferAmount = playerBalances[msg.sender];
        playerBalances[msg.sender] = 0;
        (bool success, ) = recipient.call{value: ethTransferAmount}("");
        require(success, "Transfer failed");

        emit LogRewardsClaimed(ethTransferAmount, msg.sender);
    }

    ///@notice this is a Callback method which is getting called in RandomConsumerNumber.sol
    function saveRandomNumber(uint256 n) internal override {
        randomNumber = n;
    }

    ///@notice this is a Callback method which is getting called in FundLink.sol after swapping ETH for LINk
    function setPaidEthAmountForLinkSwap(uint256 amount) internal override {
        paidEthAmountForLinkSwap = amount;
    }

    function setStartRoundIncentive(uint256 incentive) onlyDAO external {
        startRoundIncetive = incentive;
    }

    function setFinishRoundIncentive(uint256 incentive) onlyDAO external {
        finishRoundIncetive = incentive;
    }

    receive() external payable {}
}