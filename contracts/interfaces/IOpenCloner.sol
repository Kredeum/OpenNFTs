// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenCloner {
  function clone(address template) external returns (address);
}
