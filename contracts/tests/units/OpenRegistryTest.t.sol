// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenRegistry.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/templates/OpenNFTsEx.sol";

abstract contract OpenRegistryTest is Test {
    address private _resolver;
    address private _collection;
    address private _owner = address(0x1);

    bytes4 private _idNull = 0xffffffff;
    bytes4 private _idIERC165 = type(IERC165).interfaceId;
    bytes4 private _idRegistry = type(IOpenRegistry).interfaceId;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenRegistry() public {
        _resolver = constructorTest(_owner);

        bool[] memory options = new bool[](1);
        options[0] = true;
        _collection = address(new OpenNFTsEx());
        IOpenNFTsEx(_collection).initialize("ERC721", "NFT", _owner, options);
    }

    function testOpenRegistryAddAddress() public {
        address[] memory addrs = new address[](1);
        addrs[0] = _collection;

        assertEq(IOpenRegistry(_resolver).countAddresses(), 0);
        IOpenRegistry(_resolver).addAddresses(addrs);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 1);
    }

    function testOpenRegistryBurnAddress() public {
        address[] memory addrs = new address[](1);
        addrs[0] = _collection;

        assertEq(IOpenRegistry(_resolver).countAddresses(), 0);
        IOpenRegistry(_resolver).addAddresses(addrs);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 1);
        IOpenRegistry(_resolver).addAddresses(addrs);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 2);
        IOpenRegistry(_resolver).addAddresses(addrs);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 3);
        IOpenRegistry(_resolver).burnAddress(1);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 2);
        IOpenRegistry(_resolver).burnAddress(1);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 1);
        IOpenRegistry(_resolver).burnAddress(0);
        assertEq(IOpenRegistry(_resolver).countAddresses(), 0);
    }

    function testOpenRegistrySupportsInterface() public {
        assertFalse(IERC165(_resolver).supportsInterface(_idNull));
        assertTrue(IERC165(_resolver).supportsInterface(_idIERC165));
        assertTrue(IERC165(_resolver).supportsInterface(_idRegistry));
    }
}
