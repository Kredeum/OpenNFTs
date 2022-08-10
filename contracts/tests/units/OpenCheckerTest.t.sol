// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenChecker.sol";
import "OpenNFTs/contracts/templates/OpenResolverEx.sol";

abstract contract OpenCheckerTest is Test {
    address private _collection;
    address private _owner = address(0x1);

    bytes4 private _idIERC165 = type(IERC165).interfaceId;
    bytes4 private _idNull = 0xffffffff;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenChecker() public {
        _collection = constructorTest(_owner);
    }

    function testOpenCheckerSupportsInterface() public {
        assertTrue(IERC165(_collection).supportsInterface(_idIERC165));
        assertFalse(IERC165(_collection).supportsInterface(_idNull));
    }

    function testOpenCheckerCheckSupportedInterfaces() public {
        bytes4[2] memory ids = [_idIERC165, _idNull];
        bool[2] memory expected = [true, false];

        bytes4[] memory interfaceIds = new bytes4[](2);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        OpenResolverEx resolver;
        resolver = new OpenResolverEx();
        bool[] memory checks = IOpenChecker(resolver).checkSupportedInterfaces(_collection, interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
