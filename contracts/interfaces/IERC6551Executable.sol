// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC6551Executable {
  function execute(address, uint256, bytes calldata, uint256)
    external
    payable
    returns (bytes memory);
}
