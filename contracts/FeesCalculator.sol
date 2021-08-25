//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FeesCalculator {
    using SafeMath for uint256;

    uint256 public daoFeeBps;
    uint256 public operationalFeeBps;

    constructor(uint256[] memory fees) {
        daoFeeBps = fees[1];
        operationalFeeBps = fees[2];
    }

    /// @notice Calculates the Fees for pool participation
    /// @param wager he amount of wager to calculate for
    /// @param ethAmount the ETH amount needed for RNG request
    /// @param poolLength the count of participants to split the fee for LINK
    function getFeesAmount(uint256 wager, uint256 ethAmount, uint256 poolLength, uint256 startRoundIncetive, uint256 finishRoundIncetive) public view returns (uint256) {
        uint256 daoFee = _calculateDAOfee(wager, daoFeeBps);
        uint256 operationalFee = _calculateOperationalFees(ethAmount, poolLength);
        return daoFee.add(operationalFee).add(startRoundIncetive).add(finishRoundIncetive);
    }

    /// @notice Subtracts predefined fee which will be used for covering fees for calling executeRound() and getting LINK for random number generation.
    function _calculateOperationalFees(uint256 _ethAmount, uint256 _poolLength) internal pure returns (uint256) {
        return _ethAmount.div(_poolLength);
    }

    /// @notice Subtracts predefined DAO fee in BPS and sends it to the DAO/Treasury
    function _calculateDAOfee(uint256 _wagerAmount, uint256 _daoFeeBps) internal pure returns (uint256) {
        return _daoFeeBps.mul(_wagerAmount).div(10000);
    }

    /// @notice Calculates incetive fee
    function calculateIncetivise(uint256 _incentiveFee, uint256 poolLength) internal pure returns (uint256) {
        return _incentiveFee.mul(poolLength);
    }
}