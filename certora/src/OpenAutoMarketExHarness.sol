// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {OpenAutoMarketEx} from "OpenNFTs/contracts/examples/OpenAutoMarketEx.sol";
import {Receiver} from "./Receiver.sol";
contract OpenAutoMarketExHarness is OpenAutoMarketEx {
    function getEthBalance(address account) public view returns (uint256) {
        return account.balance;
    }

    function _transferValue(address account, uint256 amount)
        internal
        override
        returns (uint256)
    {
        require(address(this).balance >= amount, "Insufficient balance");

        bool success = Receiver(payable(account)).sendTo{value: amount}();

        return success ? amount : 0;
    }
}
