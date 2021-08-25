//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @notice this is a Mock Contract used for testing
contract PolymorphWithGeneChanger is ERC721 {
    constructor() ERC721("MyNFT", "MNFT") { }

    function geneOf(uint256 polymorphId) external pure returns (uint256 gene){
        require(polymorphId != 0, "You must provide a polymorphId !");
        return 17368369380818656250118163241295241385302193006429628184032061151489786639768;
    }

    function mint(address to, uint256 tokenId) public payable {
        _safeMint(to, tokenId);
    }
}