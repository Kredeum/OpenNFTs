// SPDX-License-Identifier: MIT
//
// EIP-721: Non-Fungible Token Standard
// https://eips.ethereum.org/EIPS/eip-721
//
// Derived from OpenZeppelin Contracts (token/ERC721/ERC721.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721/ERC721.sol
//      OpenERC165
//           |
//      OpenERC721
//           |
//  OpenERC721TokenReceiver —— IERC721TokenReceiver
//
pragma solidity ^0.8.19;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721TokenReceiver.sol";

contract OpenERC721TokenReceiver is IERC721TokenReceiver {
  function onERC721Received(address, address, uint256, bytes calldata)
    external
    virtual
    override(IERC721TokenReceiver)
    returns (bytes4)
  {
    return OpenERC721TokenReceiver.onERC721Received.selector;
  }
}
