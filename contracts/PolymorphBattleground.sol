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
    // TODO:: after some time (10 blocks or more) or upon receinvg the event, call battlePolymorphs, take the random number and start the battle flow
    // TODO:: battle flow: make two random numbers from the random number -> pick 2 polymorphs -> take 2 new random numbers -> calculate their attack/defence -> do the comaprison
    // TODO:: Upon selecting the first morph move it to the end of the array (we need to create it)
    // TODO:: Decrease the possible max number to be array - 1 , so we cannot take the first chosen one
    // TODO:: Move the second morph to the end
    // TODO:: should we lock them, so they cannot be picked during the execution ?
    // TODO:: Pop them from the array
    // TODO:: Battle them (compare their stats)
    // TODO:: Handle WIN/LOSE/DRAW
    // TODO:: Upon win/lose -> adjust owners balances
    // TODO:: Upon draw -> choose the winner based on the random numbers which were drawn for the stats calculation
    // TODO:: claimRewards -> ?

    enum WagerCurrency {
        XYZ,
        ETH
    }

    struct BattleEntitiy {
        bool locked; // Gets true when the battle has started
        bool inBattlePool; // Gets true upon added into the battle pool in enterBattle()
        uint256 id;
        uint256 statsMin;
        uint256 statsMax;
        uint256 skillType;
        address owner;
    }

    struct Balance {
        uint256 xyzBalance;
        uint256 ethBalance;
    }

    mapping(uint256 => BattleEntitiy) public polymorphs;
    mapping(bytes32 => uint256) public vrfIdtoMorphId;
    mapping(address => Balance) public playerBalances;
    uint256[] public battlePool;
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
        require(!polymorphs[polymorphId].locked, "Your polymorph has already been locked for the battle que !");

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
            entitiy.locked = false;
            entitiy.statsMin = min;
            entitiy.statsMax = max;
            entitiy.skillType = skillType;
            entitiy.owner = msg.sender;
            // Insert into the mapping
            polymorphs[polymorphId] = entitiy;
        }

        // 6. Enter the battle pool
        if (!entitiy.inBattlePool) {
            entitiy.inBattlePool = true;
            battlePool.push(polymorphId);
        }
    }

    /**
     * Callback function used by VRF Coordinator
     */
    // function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    //     randomResult = randomness;


        // Take the id of the polymorph which made the random number request
        // uint256 polymorphId = vrfIdtoMorphId[requestId];
        // Take the saved entity by ID
        // BattleEntitiy storage entity = battlePool[polymorphId];
        // Generate random numbers for all the genes
        // uint256[] memory genesRandoms = expand(randomness, genePairsCount);

        // Calculate stats
        // entity.stats = getStatsPoints(polymorphId, genesRandoms, entity.skillType);
        // entity.registered = true;
    // }

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
    /// @param polymorphId The id of the polymorph which will battle
    /// @param polymorphId_ The id of the polymorph which will battle
    function battlePolymorphs(uint256 polymorphId, uint256 polymorphId_)
        internal
    {
        // TODO:: Before the round lock the polymorph
        // TODO:: After the round unlock the polymorph
        // TODO:: After the round allow executeRound
        // battle flow: make two random numbers from the random number -> pick 2 polymorphs -> take 2 new random numbers -> calculate their attack/defence -> do the comaprison
        uint256[] memory randoms = expand(randomness, 2);

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
