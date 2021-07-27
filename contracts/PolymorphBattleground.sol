//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PolymorphWithGeneChanger.sol";
import "./PolymorphGeneParser.sol";
import "./IUniswapV3Router.sol";
import "./RandomConsumerNumber.sol";

contract PolymorphBattleground is PolymorphGeneParser, RandomNumberConsumer, ReentrancyGuard {
    address public polymorphsContractAddress;
    address payable public daoAddress;
    address private linkAddress;
    address private wethAddress;
    address private xyzAddress;
    IUniswapV3Router private uniswapV3Router;

    enum BattleStances {
        ATTACK,
        DEFFENCE
    }

    struct BattleEntitiy {
        bool registered;
        uint256 id;
        uint256 stats;
        uint256 skillType;
        address owner;
    }

    struct Balance {
        uint256 xyzBalance;
        uint256 ethBalance;
    }

    mapping(uint256 => BattleEntitiy) public battlePool;
    mapping(bytes32 => uint256) public vrfIdtoMorphId;
    mapping(address => Balance) public playerBalances;
    uint256 private enterFee = 0.1 ether;
    uint256 public battlePoolLength = 0;

    modifier onlyDAO() {
        require(msg.sender == daoAddress, "Not called from the dao");
        _;
    }

    constructor(address contractAddress, address payable _daoAddress, address _uniswapV3Router, address _linkAddress, address _wethAddress, address _xyzAddress) {
        //TODO:: Add events
        polymorphsContractAddress = contractAddress;
        daoAddress = _daoAddress;
        linkAddress = _linkAddress;
        wethAddress = _wethAddress;
        xyzAddress = _xyzAddress;
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
        require(!battlePool[polymorphId].registered, "Your polymorph has already been registered for the battle que !");
        // TODO:: Transfer the wager to the contract how ??

        BattleEntitiy memory entitiy = BattleEntitiy({
            id: polymorphId,
            registered: false,
            stats: 0,
            skillType: skillType,
            owner: msg.sender
            });

        // 6. Enter the battle pool
        battlePool[polymorphId] = entitiy;
        battlePoolLength += 1;

        bytes32 requestId = getRandomNumber();
        vrfIdtoMorphId[requestId] = polymorphId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;

        // TODO:: distinguish enter battle calls and get random number calls somehow by the requestId

        // Take the id of the polymorph which made the random number request
        uint256 polymorphId = vrfIdtoMorphId[requestId];
        // Take the saved entity by ID
        BattleEntitiy storage entity = battlePool[polymorphId];
        // Generate random numbers for all the genes
        uint256[] memory genesRandoms = expand(randomness, genePairsCount);

        // Calculate stats
        entity.stats = getStatsPoints(polymorphId, genesRandoms, entity.skillType);
        entity.registered = true;
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will pull two random polymorphs from the battle pool using the Chainlink VRF
    function executeRound() external {}

    /// @notice Calculates the attack score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getStatsPoints(uint256 polymorphId, uint256[] memory genesRandoms, uint256 skillType) public view returns (uint256) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate stats points for no Gene");
        return getStats(gene, genesRandoms, skillType);
    }

    /// @notice The actual battle calculation where the comparison happens
    /// @param polymorphId The id of the polymorph which will battle
    /// @param polymorphId_ The id of the polymorph which will battle
    function battlePolymorphs(uint256 polymorphId, uint256 polymorphId_)
        internal
    {}

    /// @notice Get the attack/deffence range of specific attribute. Use Chainlink VRF to select randomly number within the predefined range.
    /// @param trait - The trait
    /// @param gene - The gene
    function getBattleAttributeRange(uint256 trait, uint256 gene)
        internal
        view
    {}

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

    /// @notice Subtracts predefined fee which will be used for covering fees for calling executeRound() and getting LINK for random number generation.
    function subtractOperationalFees() internal {}

    /// @notice Subtracts predefined DAO fee in BPS and sends it to the DAO/Treasury
    function subtractDAOfee() internal {}

    receive() external payable {}
}
