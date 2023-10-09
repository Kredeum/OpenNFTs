// SPDX-License-Identifier: MIT
//
// Derived from Kredeum NFTs
// https://github.com/Kredeum/kredeum
//
//   OpenERC165
//   (supports)
//       |
//   OpenERC721
//     (NFT)
//       |
//   OpenNFTsSimpleEx —— IOpenNFTsSimpleEx
//
pragma solidity ^0.8.0;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/tests/interfaces/IOpenNFTsSimpleEx.sol";

contract OpenNFTsSimpleEx is IOpenNFTsSimpleEx, OpenERC721 {
  uint256 public tokenCount;

  function mint(string memory tokenURI)
    external
    override(IOpenNFTsSimpleEx)
    returns (uint256 tokenId)
  {
    tokenId = tokenCount++;
    _mint(msg.sender, tokenURI, tokenId);
  }
}
