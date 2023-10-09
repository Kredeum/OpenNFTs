// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC6551Registry {
  event AccountCreated(
    address, address indexed, uint256, address indexed, uint256 indexed, uint256
  );
  function createAccount(address, uint256, address, uint256, uint256, bytes calldata iitData)
    external
    returns (address);
  function account(address, uint256, address, uint256, uint256) external view returns (address);
}
