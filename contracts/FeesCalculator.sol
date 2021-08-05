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

    /// @notice Calculates the Fees for pool participation
    /// @param wager he amount of wager to calculate for
    /// @param ethAmount the ETH amount needed for RNG request
    /// @param poolLength the count of participants to split the fee for LINK
    function getFeesAmount(uint256 wager, uint256 ethAmount, uint256 poolLength) public view returns (uint256) {
        uint256 daoFee = _calculateDAOfee(wager, daoFeeBps);
        uint256 operationalFee = _calculateOperationalFees(ethAmount, poolLength);
        return daoFee.add(operationalFee);
    }

    /// @notice Subtracts predefined fee which will be used for covering fees for calling executeRound() and getting LINK for random number generation.
    function _calculateOperationalFees(uint256 _ethAmount, uint256 _poolLength) internal pure returns (uint256) {
        return _ethAmount.div(_poolLength);
    }

    /// @notice Subtracts predefined DAO fee in BPS and sends it to the DAO/Treasury
    function _calculateDAOfee(uint256 _wagerAmount, uint256 _daoFeeBps) internal pure returns (uint256) {
        return _daoFeeBps.mul(_wagerAmount).div(10000);
    }
}