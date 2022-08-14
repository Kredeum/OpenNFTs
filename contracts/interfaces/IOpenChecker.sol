// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenChecker {
    function checkErcInterfaces(address smartcontract) external view returns (bool[] memory);

    function checkSupportedInterfaces(address smartcontract, bytes4[] memory interfaceIds)
        external
        view
        returns (bool[] memory);
}
