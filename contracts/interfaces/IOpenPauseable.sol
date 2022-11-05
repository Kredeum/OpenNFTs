// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOpenPauseable {
    event SetPaused(bool indexed paused, address indexed account);

    function paused() external returns (bool);

    function togglePause() external;
}
