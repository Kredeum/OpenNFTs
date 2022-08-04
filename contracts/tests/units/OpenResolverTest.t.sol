// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/templates/OpenNFTsEx.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenResolver.sol";
import "OpenNFTs/contracts/interfaces/IOpenRegistry.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/interfaces/IOpenChecker.sol";

abstract contract OpenResolverTest is Test {
    address private _collection;
    address private _owner = address(0x1);

    bytes4 public idIERC165 = type(IERC165).interfaceId;
    bytes4 public idOpenResolver = type(IOpenResolver).interfaceId;
    bytes4 public idOpenRegistry = type(IOpenRegistry).interfaceId;
    bytes4 public idOpenGetter = type(IOpenGetter).interfaceId;
    bytes4 public idOpenChecker = type(IOpenChecker).interfaceId;
    bytes4 public idNull = 0xffffffff;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenResolver() public {
        _collection = constructorTest(_owner);
    }

    function testOpenResolverSupportsInterface() public {
        assertTrue(IERC165(_collection).supportsInterface(idIERC165));
        assertTrue(IERC165(_collection).supportsInterface(idOpenResolver));
        assertTrue(IERC165(_collection).supportsInterface(idOpenRegistry));
        assertTrue(IERC165(_collection).supportsInterface(idOpenGetter));
        assertTrue(IERC165(_collection).supportsInterface(idOpenChecker));
        assertFalse(IERC165(_collection).supportsInterface(idNull));
    }

    function testOpenResolver() public {
        address[] memory addrs = new address[](1);
        bytes4[] memory ids = new bytes4[](1);
        ids[0] = bytes4(0x80ac58cd);

        bool[] memory options = new bool[](1);
        options[0] = true;

        changePrank(_owner);

        OpenNFTsEx openNFTsEx = new OpenNFTsEx();
        openNFTsEx.initialize("OpenBoundEx", "BOUND", _owner, options);
        addrs[0] = address(openNFTsEx);

        IOpenRegistry(_collection).addAddress(addrs[0]);
        assertEq(IOpenRegistry(_collection).countAddresses(), 1);
        assertEq(IOpenRegistry(_collection).addresses(0), addrs[0]);

        IOpenGetter(_collection).getCollectionsInfos(addrs, _owner);
        // IOpenGetter(_collection).getCollectionsInfos(addrs, address(0));

        // IOpenResolver(_collection).openResolver(_owner);
        // IOpenResolver(_collection).openResolver(address(0));
    }
}
