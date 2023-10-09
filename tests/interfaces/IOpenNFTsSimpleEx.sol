// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenNFTsSimpleEx {
  function mint(string memory tokenURI) external returns (uint256 tokenID);
}
