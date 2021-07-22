//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./PolymorphWithGeneChanger.sol";
import "./PolymorphGeneParser.sol";

contract PolymorphBattleground is PolymorphGeneParser {
    address public polymorphsContractAddress;

    enum BattleStances {
        ATTACK,
        DEFFENCE
    }

    struct BattleEntitiy {
        bool registered;
        uint256 id;
        uint256 attack;
        uint256 defence;
        uint256 skillType;
        address owner;
    }

    mapping(uint256 => BattleEntitiy) public battlePool;
    uint256 private enterFee = 0.1 ether;
    uint256 public battlePoolLength = 0;

    constructor(address contractAddress) {
        //TODO:: pass DAO collection fees Address !
        //TODO:: Implement supported ERC20 tokens mapping and allow to use tokens only from this list
        polymorphsContractAddress = contractAddress;
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
        // TODO:: Use only one method for getting attack and defence, no need to do 2 parsings of the gene
        // TODO:: There may be no need for geting both attack and defence
        BattleEntitiy memory entitiy = BattleEntitiy({
            id: polymorphId,
            registered: true,
            attack: getAttack(polymorphId),
            defence: getDefence(polymorphId),
            skillType: skillType,
            owner: msg.sender
            });

        // 6. Enter the battle pool
        battlePool[polymorphId] = entitiy;
        battlePoolLength += 1;
    }

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will pull two random polymorphs from the battle pool using the Chainlink VRF
    function executeRound() external {}

    /// @notice Calculates the attack score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getAttack(uint256 polymorphId) public view returns (uint256) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate attack points for no Gene");
        uint256 attack = parseAttack(gene);
        return attack;
    }

    /// @notice Calculates the defence score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getDefence(uint256 polymorphId) public view returns (uint256) {
        PolymorphWithGeneChanger polymorphsContract = PolymorphWithGeneChanger(polymorphsContractAddress);
        uint256 gene = polymorphsContract.geneOf(polymorphId);
        require(gene != 0, "Cannot calculate defence points for no Gene");
        uint256 defence = parseDefence(gene);
        return defence;
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

    /// @notice Deducts a portion from the wager and converts it to LINK, so costs can be coverd for RNG generation
    function getLinkForRNGCosts() internal {}

    /// @notice Updates the player balance reward after finished battle
    /// @param player - The address of the player
    function upadteRewardBalance(address player) internal {}

    /// @notice Claims the available balance of player
    function claimRewards() external {}

    /// @notice Subtracts predefined fee which will be used for covering fees for calling executeRound() and getting LINK for random number generation.
    function subtractOperationalFees() internal {}

    /// @notice Subtracts predefined DAO fee in BPS and sends it to the DAO/Treasury
    function subtractDAOfee() internal {}

    receive() external payable {}
}
