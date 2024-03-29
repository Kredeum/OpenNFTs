// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERCNftInfos.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/tests/examples/OpenNFTsEx.sol";
import {ERC1155Ex} from "OpenNFTs/tests/ERC1155Ex/ERC1155Ex.sol";

abstract contract OpenGetterTest is Test, IERCNftInfos {
  address private _resolver;
  address private _collection;
  address private _owner = makeAddr("owner");
  address private _tester = makeAddr("tester");
  address private _random = makeAddr("random");

  uint256 private _tokenID0;
  uint256 private _tokenID1;
  uint256 private _tokenID2;
  string private constant _TOKEN_URI =
    "ipfs://bafkreidfhassyaujwpbarjwtrc6vgn2iwfjmukw3v7hvgggvwlvdngzllm";

  bytes4 private _idNull = 0xffffffff;
  bytes4 private _idIERC165 = type(IERC165).interfaceId;
  bytes4 private _idIERC173 = type(IERC173).interfaceId;
  bytes4 private _idGetter = type(IOpenGetter).interfaceId;

  function constructorTest(address owner_) public virtual returns (address);

  function setUpOpenGetter() public {
    _resolver = constructorTest(_owner);

    vm.startPrank(_owner);
    bool[] memory options = new bool[](2);
    options[0] = true;
    _collection = address(new OpenNFTsEx());
    IOpenNFTsEx(_collection).initialize("ERC721", "NFT", _owner, payable(address(0x7)), 0, options);

    _tokenID0 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
    _tokenID1 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
    _tokenID2 = IOpenNFTsEx(_collection).mint(_TOKEN_URI);
    vm.stopPrank();
  }

  function testERC1155OpenGetter() public {
    ERC1155Ex eRC1155Ex = new ERC1155Ex();

    vm.prank(_owner);
    eRC1155Ex.mint(10);

    NftInfos memory nftInfos = IOpenGetter(_resolver).getNftInfos(address(eRC1155Ex), 0, msg.sender);
    assertEq(nftInfos.tokenID, 0);
    assertEq(nftInfos.owner, address(0)); // no owner for ERC1155
  }

  function testOpenGetterGetNftInfos1() public {
    NftInfos memory nftInfos =
      IOpenGetter(_resolver).getNftInfos(address(_collection), _tokenID0, _random);
    assertEq(nftInfos.tokenID, _tokenID0);
    assertEq(nftInfos.tokenURI, _TOKEN_URI);
    assertEq(nftInfos.owner, _owner);
    assertEq(nftInfos.approved, address(0));
  }

  // invalid tokenID to not revert
  function testOpenGetterGetNftInfos2() public {
    NftInfos memory nftInfos = IOpenGetter(_resolver).getNftInfos(address(_collection), 9, _random);
    assertEq(nftInfos.tokenID, 9);
    assertEq(nftInfos.tokenURI, "");
    assertEq(nftInfos.owner, address(0));
    assertEq(nftInfos.approved, address(0));
  }

  function testOpenGetterGetNftsInfos1() public {
    (NftInfos[] memory nftsInfos, uint256 count, uint256 total) =
      IOpenGetter(_resolver).getNftsInfos(address(_collection), _owner, 0, 0);
    assertEq(nftsInfos.length, 0);
    assertEq(count, 0);
    assertEq(total, 3);
  }

  function testOpenGetterGetNftsInfos2() public {
    (NftInfos[] memory nftsInfos, uint256 count, uint256 total) =
      IOpenGetter(_resolver).getNftsInfos(address(_collection), _owner, 5, 0);
    assertEq(nftsInfos.length, 3);
    assertEq(nftsInfos[0].tokenID, _tokenID0);
    assertEq(nftsInfos[1].tokenID, _tokenID1);
    assertEq(nftsInfos[2].tokenID, _tokenID2);
    assertEq(count, 3);
    assertEq(total, 3);
  }

  function testOpenGetterGetNftsInfos3() public {
    (NftInfos[] memory nftsInfos, uint256 count, uint256 total) =
      IOpenGetter(_resolver).getNftsInfos(address(_collection), address(0), 0, 0);

    assertEq(nftsInfos.length, 0);
    assertEq(count, 0);
    assertEq(total, 3);
  }

  function testOpenGetterGetNftsInfos4() public {
    (NftInfos[] memory nftsInfos, uint256 count, uint256 total) =
      IOpenGetter(_resolver).getNftsInfos(address(_collection), address(0), 3, 1);

    assertEq(nftsInfos.length, 2);
    assertEq(count, 2);
    assertEq(total, 3);
  }

  function testOpenGetterGetNftsInfos5() public {
    (NftInfos[] memory nftsInfos, uint256 count, uint256 total) =
      IOpenGetter(_resolver).getNftsInfos(address(_collection), _random, 10, 0);

    assertEq(nftsInfos.length, 0);
    assertEq(count, 0);
    assertEq(total, 0);
  }

  function testOpenGetterGetCollectionInfosApprovedForAll1() public {
    CollectionInfos memory collectionInfos =
      IOpenGetter(_resolver).getCollectionInfos(address(_collection), _random);
    assertEq(collectionInfos.approvedForAll, false);
  }

  function testOpenGetterGetCollectionInfosApprovedForAll2() public {
    vm.prank(_tester);
    IERC721(_collection).setApprovalForAll(_collection, true);

    CollectionInfos memory collectionInfos =
      IOpenGetter(_resolver).getCollectionInfos(address(_collection), _tester);
    assertEq(collectionInfos.approvedForAll, true);
  }

  function testOpenGetterGetCollectionInfos() public {
    assertEq(IERC173(_collection).owner(), _owner);

    CollectionInfos memory collectionInfos =
      IOpenGetter(_resolver).getCollectionInfos(address(_collection), _random);
    assertEq(collectionInfos.collection, _collection);
    assertEq(collectionInfos.owner, _owner);
    assertEq(collectionInfos.name, "ERC721");
    assertEq(collectionInfos.symbol, "NFT");
  }

  function testOpenGetterERC173NotButOwner() public {
    ERC173NotButOwner smartcontract = new ERC173NotButOwner(_owner);
    assertEq(IERC173(address(smartcontract)).owner(), _owner);
    assertFalse(IERC165(smartcontract).supportsInterface(_idIERC173));

    CollectionInfos memory collectionInfos =
      IOpenGetter(_resolver).getCollectionInfos(address(smartcontract), _random);
    assertEq(collectionInfos.owner, _owner);
  }

  function testOpenGetterERC173Not() public {
    ERC173Not smartcontract = new ERC173Not();

    CollectionInfos memory collectionInfos =
      IOpenGetter(_resolver).getCollectionInfos(address(smartcontract), _random);
    assertEq(collectionInfos.owner, address(0));
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

contract ERC173Not is OpenERC721 {}

contract ERC173NotButOwner is OpenERC721 {
  address private _owner;

  constructor(address owner_) {
    _owner = owner_;
  }

  function owner() external view returns (address) {
    return _owner;
  }
}
