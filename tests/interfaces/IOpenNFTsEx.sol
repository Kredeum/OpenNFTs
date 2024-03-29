// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOpenNFTsEx {
  function initialize(
    string memory name,
    string memory symbol,
    address owner,
    address treasury,
    uint96 treasuryFee,
    bool[] memory options
  ) external;

  function mint(string memory tokenURI) external returns (uint256 tokenID);

  function buy(uint256 tokenID) external payable;

  function open() external view returns (bool);
}
