// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC6551Account {
  receive() external payable;
  function token() external view returns (uint256, address, uint256);
  function state() external view returns (uint256);
  function isValidSigner(address, bytes calldata) external view returns (bytes4);
}
