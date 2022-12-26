// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TransferValue {
    function getEthBalance(address account) external view returns (uint256) {
        return account.balance;
    }

    function transferValue(address to, uint256 value) external returns (uint256) {
        bool success;
        if (value > 0) {
            (success,) = to.call{value: value, gas: 2300}("");
        }
        return success ? value : 0;
    }
}
