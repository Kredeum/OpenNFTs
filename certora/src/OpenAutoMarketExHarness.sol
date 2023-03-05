// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {OpenAutoMarketEx} from "OpenNFTs/contracts/examples/OpenAutoMarketEx.sol";
import {Receiver} from "./Receiver.sol";

contract OpenAutoMarketExHarness is OpenAutoMarketEx {
    function getEthBalance(address account) public view returns (uint256) {
        return account.balance;
    }

    function getTreasury() public view returns (address) {
        return _treasury.account;
    }

    function getReceiver(uint256 tokenID) public view returns (address receiver) {
        (receiver,) = royaltyInfo(tokenID, 1 ether);
    }

    function _transferValue(address account, uint256 amount) internal override returns (uint256) {
        require(address(this).balance >= amount, "Insufficient balance");

        bool success = Receiver(payable(account)).sendTo{value: amount}();

        return success ? amount : 0;
    }
}
