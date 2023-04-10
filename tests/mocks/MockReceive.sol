// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

interface IMockReceive {
  receive() external payable;
}

contract MockReceive is IMockReceive {
  event Received(address, uint256);

  receive() external payable override(IMockReceive) {
    emit Received(msg.sender, msg.value);
  }
}

contract MockNoReceive {}
