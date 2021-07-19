//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IPolymorphWithGeneChanger.sol";

contract PolymorphBattleground {
    constructor() {}

    /// @notice The user enters a battle. The function checks whether the user is owner of the morph. Also the wager is sent to the contract and the user's morph enters the pool.
    /// @param polymorphId Id of the polymorph
    /// @param skillType Attack or Defence
    function enterBattle(uint256 polymorphId, uint256 skillType)
        external
        payable
    {}

    /// @notice Backend (like Openzeppelin Defender) will call this function periodically
    /// It will pull two random polymorphs from the battle pool using the Chainlink VRF
    function executeRound() external {}

    /// @notice Calculates the attack score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getAttack(uint256 polymorphId) public view {}

    /// @notice Calculates the defence score of the polymorph based on its gene
    /// @param polymorphId Id of the polymorph
    function getDefence(uint256 polymorphId) public view {}

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
}
