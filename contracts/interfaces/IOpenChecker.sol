// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenChecker {
    function checkSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        external
        view
        returns (bool[] memory);
}
