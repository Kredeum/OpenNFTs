// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenChecker.sol";

abstract contract OpenCheckerTest is Test {
    address private _resolver;
    address private _owner = address(0x1);

    bytes4 private _idNull = 0xffffffff;
    bytes4 private _idIERC165 = type(IERC165).interfaceId;
    bytes4 private _idChecker = type(IOpenChecker).interfaceId;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenChecker() public {
        _resolver = constructorTest(_owner);
    }

    function testOpenCheckerSupportsInterface() public {
        assertFalse(IERC165(_resolver).supportsInterface(_idNull));
        assertTrue(IERC165(_resolver).supportsInterface(_idIERC165));
        assertTrue(IERC165(_resolver).supportsInterface(_idChecker));
    }

    function testOpenCheckerErcSupportedInterfaces() public {
        /// 0xffffffff :  O Invalid
        /// 0x01ffc9a7 :  1 ERC165
        ///
        /// 0x80ac58cd :  2 ERC721
        /// 0x5b5e139f :  3 ERC721Metadata
        /// 0x780e9d63 :  4 ERC721Enumerable
        /// 0x150b7a02 :  5 ERC721TokenReceiver
        ///
        /// 0xd9b67a26 :  6 ERC1155
        /// 0x0e89341c :  7 ERC1155MetadataURI
        /// 0x4e2312e0 :  8 ERC1155TokenReceiver
        ///
        /// 0x7f5828d0 :  9 ERC173
        /// 0x2a55205a : 10 ERC2981
        bool[11] memory expected = [false, true, false, false, false, false, false, false, false, true, false];

        bool[] memory checks = IOpenChecker(_resolver).checkErcInterfaces(_resolver);

        for (uint256 i = 0; i < checks.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }

    function testOpenCheckerCheckSupportedInterfaces() public {
        bytes4[2] memory ids = [_idIERC165, _idNull];
        bool[2] memory expected = [true, false];

        bytes4[] memory interfaceIds = new bytes4[](2);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        bool[] memory checks = IOpenChecker(_resolver).checkSupportedInterfaces(_resolver, interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
