// SPDX-License-Identifier: MIT
//
// EIP-165: Standard Interface Detection
// https://eips.ethereum.org/EIPS/eip-165
//
// Derived from OpenZeppelin Contracts (utils/introspection/ERC165.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/utils/introspection/ERC165.sol
//
//  OpenERC165 —— IERC165
//
pragma solidity ^0.8.19;

import "OpenNFTs/contracts/interfaces/IERC165.sol";

abstract contract OpenERC165 is IERC165 {
  function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    return interfaceId == 0x01ffc9a7; //  type(IERC165).interfaceId
  }
}
