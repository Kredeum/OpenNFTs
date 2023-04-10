// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOpenCloner {
  function clone(address template) external returns (address);
}
