// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "OpenNFTs/contracts/examples/OpenAutoMarketEx.sol";

contract OpenAutoMarketExFuzz is OpenAutoMarketEx {
    address private _other = address(1);
    address private _receiver = address(2);
    address private _owner = address(42);

    address private _echidna = msg.sender;

    constructor() {
        initialize(_owner, payable(_receiver), 0, false);
    }

    function echidna_owner() public view returns (bool) {
        return _owner == owner();
    }

    // function transferOwner() public {
    //     _mint(_echidna, "1", 1);
    //     safeTransferFrom(_echidna, _other, 1);
    // }
    // function echidna_balance() public view returns (bool) {
    //     return balanceOf(_other) < 1;
    // }

    function echidna_balance() public view returns (bool) {
        return balanceOf(_other) < 1;
    }
}
