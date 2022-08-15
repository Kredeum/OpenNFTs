// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenRegistry {
    function burnAddress(uint256 index) external;

    function addAddresses(address[] memory addrs) external;

    function getAddresses() external view returns (address[] memory);

    function countAddresses() external view returns (uint256);
}
