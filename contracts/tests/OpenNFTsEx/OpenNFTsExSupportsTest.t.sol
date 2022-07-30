// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTs.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTsEx.sol";

abstract contract OpenNFTsExSupportsTest is Test {
    address private _collection;
    address private _owner = address(0x1);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](1);

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenNFTsExSupports() public {
        _collection = constructorTest(_owner);
    }

    function testOpenNFTsExCheckSupportedInterfaces() public {
        bytes4[14] memory ids = [
            type(IERC165).interfaceId,
            type(IERC173).interfaceId,
            type(IERC2981).interfaceId,
            type(IERC721).interfaceId,
            type(IERC721Enumerable).interfaceId,
            type(IERC721Metadata).interfaceId,
            type(IOpenCheckable).interfaceId,
            type(IOpenCloneable).interfaceId,
            type(IOpenMarketable).interfaceId,
            type(IOpenNFTs).interfaceId,
            type(IOpenNFTsEx).interfaceId,
            type(IOpenPauseable).interfaceId,
            type(IERC721TokenReceiver).interfaceId,
            0xffffffff
        ];
        bool[14] memory expected = [
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false
        ];

        bytes4[] memory interfaceIds = new bytes4[](14);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        bool[] memory checks = IOpenCheckable(_collection).checkSupportedInterfaces(interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
