// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITransferValue {
  function transferValue(address to, uint256 value) external returns (uint256);
  function getEthBalance(address account) external view returns (uint256);
}

contract TransferValue is ITransferValue {
  function transferValue(address to, uint256 value)
    external
    override(ITransferValue)
    returns (uint256)
  {
    bool success;
    if (value > 0) {
      (success,) = to.call{value: value, gas: 2300}("");
    }
    return success ? value : 0;
  }

  function getEthBalance(address account) external view override(ITransferValue) returns (uint256) {
    return account.balance;
  }
}
