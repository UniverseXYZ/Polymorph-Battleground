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

    address public polymorphsContractAddress;
    address payable public daoAddress;
    address private linkAddress;
    address private wethAddress;
    address private xyzAddress;
    IUniswapV3Router private uniswapV3Router;
    // TODO:: write docs
    // TODO:: Upon win/lose -> adjust owners balances
    // TODO:: claimRewards -> ?

    enum WagerCurrency {
        XYZ,
        ETH
    }

    struct BattleEntitiy {
        bool inBattlePool; // Gets true upon added into the battle pool in enterBattle()
        uint256 id;
        uint256 statsMin;
        uint256 statsMax;
        uint256 skillType;
        address owner;
        uint256 wins;
        uint256 loses;
        uint256 lastBattleStats;
    }

    struct Balance {
        uint256 xyzBalance;
        uint256 ethBalance;
    }

    mapping(uint256 => BattleEntitiy) public polymorphs;
    mapping(bytes32 => uint256) public vrfIdtoMorphId;
    mapping(address => Balance) public playerBalances;
    uint256[] public battlePool;
    bool public poolLocked;
    uint256 private enterFee = 0.1 ether;
    uint256 public daoFeeBps = 1000; // to be configurable
    uint256 public operationalFeeBps = 1000; // to be configurable

    modifier onlyDAO() {
        require(msg.sender == daoAddress, "Not called from the dao");
        _;
    }

    constructor(address _polymorphContractAddress, address payable _daoAddress, address _uniswapV3Router, address _linkAddress, address _wethAddress, address _xyzAddress) {
        //TODO:: Add events
        polymorphsContractAddress = _polymorphContractAddress;
        daoAddress = _daoAddress;
        linkAddress = _linkAddress;
        wethAddress = _wethAddress;
        xyzAddress = _xyzAddress;
        uniswapV3Router = IUniswapV3Router(_uniswapV3Router);
    }

    /// @notice The user enters a battle. The function checks whether the user is owner of the morph. Also the wager is sent to the contract and the user's morph enters the pool.
    /// @notice The user should be able to enter the function again with the same polymoprhId if a battle with his ID has not started, update its stats, change its owner.
    /// @param polymorphId Id of the polymorph
    /// @param skillType Attack or Defence
    function enterBattle(uint256 polymorphId, uint256 skillType)
        external
        payable
    {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        require(polymorphsContract.ownerOf(polymorphId) == msg.sender, "You must be the owner of the polymorph");
        require(msg.value >= enterFee, "The sended fee is not enough !");
        require((!polymorphs[polymorphId].inBattlePool && !poolLocked), "Your polymorph has already been locked for the battle que !");
        // Deducts the required fees and registers the wager balance to the player
        _registerWagerAndSubFees(msg.sender, msg.value);

        (uint256 min, uint256 max) = getStatsPoints(polymorphId, skillType);

        // Create or update an entity in the polymorphs mapping

        BattleEntitiy storage entitiy = polymorphs[polymorphId];

        if (entitiy.id != 0) {
            // Update an already existing entity (update stats, change owner, change skillType)
            entitiy.statsMin = min;
            entitiy.statsMax = max;
            entitiy.skillType = skillType;
            entitiy.owner = msg.sender;
        } else {
            // Add new entity
            entitiy.id = polymorphId;
            entitiy.inBattlePool = false;
            entitiy.statsMin = min;
            entitiy.statsMax = max;
            entitiy.skillType = skillType;
            entitiy.owner = msg.sender;
            entitiy.wins = 0;
            entitiy.loses = 0;
            entitiy.lastBattleStats = 0;

            // Insert into the mapping
            polymorphs[polymorphId] = entitiy;
        }

        // 6. Enter the battle pool
        if (!entitiy.inBattlePool) {
            entitiy.inBattlePool = true;
            battlePool.push(polymorphId);
        }
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will pull two random polymorphs from the battle pool using the Chainlink VRF
    function executeRound() external {
        require(!lockExecuteRound, "Round execution has been locked !");
        lockExecuteRound = true;
        getRandomNumber();
    }

    /// @notice Calculates the attack score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getStatsPoints(uint256 polymorphId, uint256 skillType) public view returns (uint256 min, uint256 max) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate stats points for no Gene");
        return getStats(gene, skillType);
    }

    /// @notice The actual battle calculation where the comparison happens
    function battlePolymorphs()
        public
    {
        require(battlePool.length >= 2, "Not enough polymorphs into the Battle Pool !");
        require(randomResult != 0 && lockExecuteRound, "Random result is 0");

        // Lock the battlePool so entities cannot be updated, re-entered
        poolLocked = true;

        // Take random numbers for picking opponents
        uint256[] memory randoms = expand(randomResult, 2);

        // Take a random number between that range from 0 and take the polymorph behind it
        uint256 first = randoms[0] % (battlePool.length - 1);
        BattleEntitiy storage entitiy = polymorphs[battlePool[first]];

        // Move the polymorph to the end of the array and pop it
        swapAndPopBattleEntity(first);

        // Take second random number from the range
        uint256 second;
        if (battlePool.length - 1 < 1) second = randoms[1] % 1; // if the length is 1 we should take 1 otherwise number % 0 = NaN
        else second = randoms[1] % (battlePool.length - 1);

        BattleEntitiy storage entitiy2 = polymorphs[battlePool[second]];
        // Move the polymorph to the end of the array and pop it
        swapAndPopBattleEntity(second);

        // Take random numbers for stats calculations
        uint256[] memory statsRandoms = expand(randoms[1], 2);
        uint256 statsFirst = entitiy.statsMin + (statsRandoms[0] % (entitiy.statsMax - entitiy.statsMin));
        uint256 statsSecond = entitiy2.statsMin + (statsRandoms[1] % (entitiy2.statsMax - entitiy2.statsMin));

        if (statsFirst > statsSecond) {
            entitiy.wins = entitiy.wins + 1;
            entitiy2.loses = entitiy2.loses + 1;
        }

        if (statsSecond > statsFirst) {
            entitiy.loses = entitiy.loses + 1;
            entitiy2.wins = entitiy2.wins + 1;
        }

        // Equal stats case, select the winner based on the random numbers used for forming the stats
        if (statsFirst == statsSecond) {
            if (statsRandoms[0] > statsRandoms[1]) {
                entitiy.wins = entitiy.wins + 1;
                entitiy2.loses = entitiy2.loses + 1;
            } else {
                entitiy.loses = entitiy.loses + 1;
                entitiy2.wins = entitiy2.wins + 1;
            }
        }

        // Save last stats points
        entitiy.lastBattleStats = statsFirst;
        entitiy2.lastBattleStats = statsSecond;

        // Exit the battle pool
        entitiy.inBattlePool = false;
        entitiy2.inBattlePool = false;

        // Reset randomResult
        randomResult = 0;

        // Allow executeRound
        lockExecuteRound = false;

        // Unlock the battlePool so entities can be updated, re-entered
        poolLocked = false;
    }

    /// @notice Moves battle entity to the end of the pool and pops it out
    function swapAndPopBattleEntity(uint256 index) public {
        // If its not already the last element
        if (index != battlePool.length - 1) {
            uint256 temp = battlePool[battlePool.length - 1];
            uint256 curr = battlePool[index];
            // Move the current to the end
            battlePool[battlePool.length - 1] = curr;
            // Put the last one on the current place
            battlePool[index] = temp;
            // Remove the last element
        }
        // Remove the element
        battlePool.pop();
    }

    /// @notice converts it to LINK, so costs can be coverd for RNG generation
    /// @param linkAmount Exact LINK(Chainlink) amount to swap
    function getLinkForRNGCosts(uint256 linkAmount) public payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");
        require(linkAmount > 0, "Must pass non 0 LINK amount");

        uint256 deadline = block.timestamp + 60;
        address tokenIn = wethAddress;
        address tokenOut = linkAddress;
        uint24 fee = 3000;
        address recipient = address(this);
        uint256 amountOut = linkAmount;
        uint256 amountInMaximum = msg.value;
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

        uniswapV3Router.exactOutputSingle{ value: msg.value }(params);
        uniswapV3Router.refundETH();

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Refund Failed");
    }

    /// @notice Updates the player balance reward after finished battle
    /// @param player - The address of the player
    function upadteRewardBalance(address player) internal {
        // TODO :: update the playerBalances mapping
    }

    /// @notice Claims the available balance of player
    function claimRewards() external nonReentrant {
        Balance storage playerBalance = playerBalances[msg.sender];
        address payable recipient = payable(msg.sender);

        if (playerBalance.xyzBalance > 0) {
            uint256 xyzTransferAmount = playerBalance.xyzBalance;
            playerBalance.xyzBalance = 0;
            require(IERC20(xyzAddress).transferFrom(address(this), msg.sender, xyzTransferAmount), "Transfer failed");
        }

        if (playerBalance.ethBalance > 0) {
            uint256 ethTransferAmount = playerBalance.ethBalance;
            playerBalance.ethBalance = 0;
            (bool success, ) = recipient.call{value: ethTransferAmount}("");
            require(success, "Transfer failed");
        }
    }

    function _registerWagerAndSubFees(address player, uint256 wagerAmount) internal {
        uint256 daoFee = _calculateDAOfee(wagerAmount, daoFeeBps);
        uint256 operationalFee = _calculateOperationalFees(wagerAmount, operationalFeeBps);
        uint256 wagerAfterfees = wagerAmount.sub(daoFee).sub(operationalFee);

        // Increment the player balance with the wager amount (after fees being deducted)
        playerBalances[player].ethBalance = playerBalances[player].ethBalance.add(wagerAfterfees);
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
