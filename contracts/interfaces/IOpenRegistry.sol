// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenRegistry {
    function removeAddress(uint256 index) external;

    function addAddress(address addr) external;

    function addAddresses(address[] memory addrs) external;

    function getAddresses() external view returns (address[] memory);

    function countAddresses() external view returns (uint256);

    function isRegistered(address addr) external view returns (bool registered);

    function setRegisterer(address registerer) external;
}
