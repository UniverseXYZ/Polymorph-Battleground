//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FeesCalculator {
    using SafeMath for uint256;

    uint256 private daoFeeBps;
    uint256 private operationalFeeBps;

    constructor(uint256 _daoFeeBps, uint256 _operationalFeeBps) {
        daoFeeBps = _daoFeeBps;
        operationalFeeBps = _operationalFeeBps;
    }

    /// @notice Calculates the wager after deducted fees
    /// @param wagerAmount the amount of wager to calculate for
    /// @return the wager after the fees deduction
    function getWagerAfterFees(uint256 wagerAmount) internal view returns(uint256) {
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
}