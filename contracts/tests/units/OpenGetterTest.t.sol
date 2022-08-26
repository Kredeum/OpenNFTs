// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/templates/OpenNFTsEx.sol";

abstract contract OpenGetterTest is Test, IERC721Infos {
    address private _resolver;
    address private _collection;
    address private _owner = address(0x1);
    address private _random = address(0x9);

    uint256 private _tokenID0;
    uint256 private _tokenID1;
    uint256 private _tokenID2;
    string private constant _TOKEN_URI = "ipfs://bafkreidfhassyaujwpbarjwtrc6vgn2iwfjmukw3v7hvgggvwlvdngzllm";

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

        _tokenID0 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
        _tokenID1 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
        _tokenID2 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
    }

    function testOpenGetterGetCollectionInfos() public view {
        IOpenGetter(_resolver).getCollectionInfos(address(_collection));
    }

    function testOpenGetterGetNftInfos() public {
        NftInfos memory nftInfos = IOpenGetter(_resolver).getNftInfos(address(_collection), _tokenID0, true);
        assertEq(nftInfos.tokenID, _tokenID0);
        assertEq(nftInfos.tokenURI, _TOKEN_URI);
        assertEq(nftInfos.owner, _owner);
        assertEq(nftInfos.approved, address(0));
    }

    function testOpenGetterGetNftsInfos1() public {
        (NftInfos[] memory nftsInfos, uint256 count, uint256 total) = IOpenGetter(_resolver).getNftsInfos(
            address(_collection),
            _owner,
            0,
            0
        );
        assertEq(nftsInfos.length, 0);
        assertEq(count, 0);
        assertEq(total, 3);
    }

    function testOpenGetterGetNftsInfos2() public {
        (NftInfos[] memory nftsInfos, uint256 count, uint256 total) = IOpenGetter(_resolver).getNftsInfos(
            address(_collection),
            _owner,
            5,
            0
        );
        assertEq(nftsInfos.length, 3);
        assertEq(nftsInfos[0].tokenID, _tokenID0);
        assertEq(nftsInfos[1].tokenID, _tokenID1);
        assertEq(nftsInfos[2].tokenID, _tokenID2);
        assertEq(count, 3);
        assertEq(total, 3);
    }

    function testOpenGetterGetNftsInfos3() public {
        (NftInfos[] memory nftsInfos, uint256 count, uint256 total) = IOpenGetter(_resolver).getNftsInfos(
            address(_collection),
            address(0),
            0,
            0
        );

        assertEq(nftsInfos.length, 0);
        assertEq(count, 0);
        assertEq(total, 3);
    }

    function testOpenGetterGetNftsInfos4() public {
        (NftInfos[] memory nftsInfos, uint256 count, uint256 total) = IOpenGetter(_resolver).getNftsInfos(
            address(_collection),
            address(0),
            3,
            1
        );

        assertEq(nftsInfos.length, 2);
        assertEq(count, 2);
        assertEq(total, 3);
    }

    function testOpenGetterGetNftsInfos5() public {
        (NftInfos[] memory nftsInfos, uint256 count, uint256 total) = IOpenGetter(_resolver).getNftsInfos(
            address(_collection),
            _random,
            10,
            0
        );

        assertEq(nftsInfos.length, 0);
        assertEq(count, 0);
        assertEq(total, 0);
    }

    function testFailOpenGetterGetNftsInfos1() public view {
        IOpenGetter(_resolver).getNftsInfos(address(_collection), _owner, 1, 4);
    }

    function testFailOpenGetterGetNftsInfos2() public view {
        IOpenGetter(_resolver).getNftsInfos(address(0), _owner, 0, 3);
    }

    function testOpenGetterSupportsInterface() public {
        assertFalse(IERC165(_resolver).supportsInterface(_idNull));
        assertTrue(IERC165(_resolver).supportsInterface(_idIERC165));
        assertTrue(IERC165(_resolver).supportsInterface(_idGetter));
    }
}
