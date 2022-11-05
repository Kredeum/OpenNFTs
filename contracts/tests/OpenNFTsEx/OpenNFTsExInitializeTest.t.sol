// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/examples/IOpenNFTsEx.sol";

abstract contract OpenNFTsExInitializeTest is Test {
    address private _collection;
    address private _owner = address(0x1);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](2);
    address payable private _treasury = payable(address(0x7));
    uint96 private _treasuryFee = 0;

    function constructorTest(address owner_, bool init_) public virtual returns (address);

    function setUpOpenNFTsExInitialize() public {
        _collection = constructorTest(_owner, false);

        _options[0] = true;
        _options[1] = false;
    }

    function testInitializeDirect() public {
        IOpenCloneable(_collection).initialize(
            "OpenERC721Test", "TEST", _owner, abi.encode(_treasury, _treasuryFee, _options)
        );
        assertEq(IERC721Metadata(_collection).name(), "OpenERC721Test");
        assertEq(IERC721Metadata(_collection).symbol(), "TEST");
        assertEq(IERC173(_collection).owner(), _owner);
        assertEq(IOpenNFTsEx(_collection).open(), true);
    }

    function testInitializeParam() public {
        IOpenNFTsEx(_collection).initialize(
            "OpenERC721Test", "TEST", _owner, payable(address(0x7)), 0, _options
        );
        assertEq(IERC721Metadata(_collection).name(), "OpenERC721Test");
        assertEq(IERC721Metadata(_collection).symbol(), "TEST");
        assertEq(IERC173(_collection).owner(), _owner);
        assertEq(IOpenNFTsEx(_collection).open(), true);
    }

    function testInitializeNotOpen() public {
        _options[0] = false;
        IOpenNFTsEx(_collection).initialize(
            "OpenERC721Test", "TEST", _owner, payable(address(0x7)), 0, _options
        );
        assertEq(IOpenNFTsEx(_collection).open(), false);
    }

    function testFailInitializeTwice() public {
        IOpenNFTsEx(_collection).initialize(
            "OpenERC721Test", "TEST", _owner, payable(address(0x7)), 0, _options
        );
        IOpenNFTsEx(_collection).initialize(
            "OpenNFTsOldTestTwice", "OPTEST2", _tester, payable(address(0x7)), 0, _options
        );
    }
}
