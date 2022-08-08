// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenRegistry {
    function addresses(uint256 index) external returns (address);

    function addAddress(address addr) external;

    function addAddresses(address[] memory addrs) external;

    function countAddresses() external view returns (uint256);
}
