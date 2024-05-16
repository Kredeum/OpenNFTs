// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {OpenAutoMarketEx} from "OpenNFTs/tests/examples/OpenAutoMarketEx.sol";
import {Receiver} from "./Receiver.sol";

contract OpenAutoMarketExHarness is OpenAutoMarketEx {
  function getTreasury() public view returns (address) {
    return treasury.account;
  }

  function getRoyaltyReceiver(uint256 tokenID) public view returns (address receiver) {
    (receiver,) = royaltyInfo(tokenID, 1 ether);
  }

  function getRoyaltyAmount(uint256 tokenID, uint256 price) public view returns (uint256 amount) {
    (, amount) = royaltyInfo(tokenID, price);
  }

  function sum4(address a1, address a2, address a3, address a4) public view returns (uint256 sum) {
    sum = a1.balance;
    if (a2 != a1) sum = sum + a2.balance;
    if (a3 != a1 && a3 != a2) sum = sum + a3.balance;
    if (a4 != a1 && a4 != a2 && a4 != a3) sum = sum + a4.balance;
  }

  function _transferValue(address to, uint256 value) internal override returns (uint256 transfered) {
    bool success;
    if (value > 0) {
      success = Receiver(payable(to)).sendTo{value: value, gas: 2300}();
    }
    transfered = success ? value : 0;
  }
}
