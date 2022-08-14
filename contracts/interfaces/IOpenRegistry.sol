// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenRegistry {
    function burnAddress(uint256 index) external;

    function addAddresses(address[] memory addrs) external;

    function getAddress(uint256 index) external view returns (address addr);

    function countAddresses() external view returns (uint256);
}
