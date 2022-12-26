// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

contract MockReceive {
    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}

contract MockNoReceive {}
