// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/interfaces/IOpenBoundEx.sol";

abstract contract OpenBoundExSupportsTest is Test {
    address private _collection;
    address private _owner = address(0x1);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](1);

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenBoundExSupports() public {
        _collection = constructorTest(_owner);
    }

    function testOpenBoundExCheckSupportedInterfaces() public {
        //
        //    IERC165
        //       |
        //  IOpenChecker
        //       |
        //       ————————————————————————
        //       |                      |
        //    IERC721          IOpenCloneable
        //       |                      |
        //       |                      |
        //    IERC173                   |
        //       |                      |
        // IOpenPauseable               |
        //       |                      |
        //       ————————————————————————
        //       |
        //  IOpenBoundEx --- IERC721Enumerable --- IERC721Metadata
        //
        bytes4[13] memory ids = [
            type(IERC165).interfaceId,
            type(IOpenChecker).interfaceId,
            type(IERC721).interfaceId,
            type(IERC173).interfaceId,
            type(IOpenPauseable).interfaceId,
            type(IOpenCloneable).interfaceId,
            type(IOpenBoundEx).interfaceId,
            type(IERC721Enumerable).interfaceId,
            type(IERC721Metadata).interfaceId,
            type(IERC2981).interfaceId,
            type(IERC721TokenReceiver).interfaceId,
            type(IOpenMarketable).interfaceId,
            0xffffffff
        ];
        bool[13] memory expected = [true, true, true, true, true, true, true, true, true, false, false, false, false];

        bytes4[] memory interfaceIds = new bytes4[](13);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        bool[] memory checks = IOpenChecker(_collection).checkSupportedInterfaces(_collection, interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
