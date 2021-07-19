//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IPolymorphWithGeneChanger is IERC721 {
    function geneOf(uint256 tokenId) external view returns (uint256 gene);
}