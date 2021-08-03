//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library PolymorphGeneParser {
    using SafeMath for uint256;

    /// @notice Use this method to split a gene into usabe gene pairs
    /// @return Reversed uint256[] containing the gene pairs [68, 97, 63, 86, 97, 48, 51, 11, 06]
    function splitGeneToPairs(uint256 gene, uint256 genePairsCount) internal pure returns (uint256[] memory ) {
        uint256 genes = gene.mod(10**(genePairsCount * 2)); // => 061151489786639768
        uint256[] memory genePairs = new uint256[](genePairsCount);
        uint256 index = 0;

        // TODO:: think of the case when you have 00, comment by George
        while (genes != 0) {
            uint256 lastDigits = uint256(genes - (genes / 100) * 100); // returns the last 2 digits
            genePairs[index] = lastDigits;
            genes /= 100;
            index = index + 1;
        }
        return genePairs;
    }
}