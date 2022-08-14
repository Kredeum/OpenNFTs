// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/templates/OpenNFTsEx.sol";

abstract contract OpenGetterTest is Test {
    address private _resolver;
    address private _collection;
    address private _owner = address(0x1);

    bytes4 private _idNull = 0xffffffff;
    bytes4 private _idIERC165 = type(IERC165).interfaceId;
    bytes4 private _idGetter = type(IOpenGetter).interfaceId;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenGetter() public {
        _resolver = constructorTest(_owner);

        bool[] memory options = new bool[](1);
        options[0] = true;
        _collection = address(new OpenNFTsEx());
        IOpenNFTsEx(_collection).initialize("ERC721", "NFT", _owner, options);
    }

    function testOpenGettergetCollectionInfos() public view {
        IOpenGetter(_resolver).getCollectionInfos(address(_collection));
    }

    function testOpenGettergetCollectionsInfos() public view {
        address[] memory addrs = new address[](1);
        addrs[0] = address(_collection);

        IOpenGetter(_resolver).getCollectionsInfos(addrs, msg.sender);
    }

    function testOpenGettergetCollectionsInfosAddressZero() public view {
        address[] memory addrs = new address[](1);
        addrs[0] = address(_collection);

        IOpenGetter(_resolver).getCollectionsInfos(addrs, address(0));
    }

    function testOpenGetterSupportsInterface() public {
        assertFalse(IERC165(_resolver).supportsInterface(_idNull));
        assertTrue(IERC165(_resolver).supportsInterface(_idIERC165));
        assertTrue(IERC165(_resolver).supportsInterface(_idGetter));
    }
}
