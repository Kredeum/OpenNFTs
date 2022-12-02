// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "OpenNFTs/contracts/examples/OpenAutoMarketEx.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC721TokenReceiver.sol";

contract OpenAutoMarketExFromInside is Test, OpenAutoMarketEx {
    address private _other = address(1);
    address private _receiver = address(2);
    address private _owner = address(42);

    function setUp() public {
        initialize(_owner, payable(_receiver), 0, false);
    }

    function testBalanceFromInside() public {
        _mint(msg.sender, "1", 1);
        safeTransferFrom(msg.sender, _other, 1);

        assertEq(balanceOf(_other), 1);
    }
}

contract OpenAutoMarketExFromOutside is Test {
    address private _other = address(1);
    address private _receiver = address(2);
    address private _random = address(3);
    address private _owner = address(42);

    OpenAutoMarketEx public openAutoMarketEx;

    function setUp() public {
        openAutoMarketEx = new OpenAutoMarketEx();
        openAutoMarketEx.initialize(_owner, payable(_receiver), 0, false);
    }

    function testBalanceFromOutside() public {
        vm.startPrank(_random);
        uint256 tokenID1 = openAutoMarketEx.mint("1");
        openAutoMarketEx.transferFrom(_random, _other, tokenID1);

        assertEq(openAutoMarketEx.balanceOf(_other), 1);
    }
}
