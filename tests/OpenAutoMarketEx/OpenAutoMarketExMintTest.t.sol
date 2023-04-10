// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {OpenAutoMarketEx} from "OpenNFTs/tests/examples/OpenAutoMarketEx.sol";

abstract contract OpenAutoMarketExMintTest is Test {
  address private _owner = makeAddr("owner");
  address private _minter = makeAddr("minter");
  address private _buyer = makeAddr("buyer");
  address private _tester = makeAddr("tester");
  bool[] private _options = new bool[](2);

  address payable private _collectionAddress;
  OpenAutoMarketEx private _collection;

  function constructorTest(address owner_) public virtual returns (address);

  function mintTest(address collection_, address minter_)
    public
    virtual
    returns (uint256 tokenID_, string memory tokenURI_);

  function setUpOpenAutoMarketExMint() public {
    address addr = constructorTest(_owner);
    _collection = OpenAutoMarketEx(payable(addr));
    _collectionAddress = payable(addr);
  }

  function testOpenAutoMarketExMint() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);
    assertTrue(tokenID == 1);
  }

  function testOpenAutoMarketExSetDefaultRoyalty() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);

    changePrank(_owner);
    _collection.setDefaultRoyalty(_minter, 100);

    (address receiver, uint256 royalties) = _collection.royaltyInfo(tokenID, 1 ether);

    assertEq(receiver, _minter);
    assertEq(royalties, 0.01 ether);
  }

  function testOpenAutoMarketExSetTokenRoyalty() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);

    changePrank(_owner);
    _collection.setTokenRoyalty(tokenID, _owner, 200);
    _collection.setDefaultRoyalty(_minter, 100);

    (address receiver, uint256 royalties) = _collection.royaltyInfo(tokenID, 1 ether);

    assertEq(receiver, _owner);
    assertEq(royalties, 0.02 ether);
  }

  function testOpenAutoMarketExSetMintPrice() public {
    changePrank(_owner);
    _collection.setMintPrice(1 ether);

    assertEq(_collection.getMintPrice(), 1 ether);
  }

  function testOpenAutoMarketExSetTokenPrice() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);

    changePrank(_owner);
    _collection.setTokenPrice(tokenID, 2 ether);
    _collection.setMintPrice(1 ether);

    assertEq(_collection.getTokenPrice(tokenID), 2 ether);
  }

  // Primary market, token not minted yet, pay token via OpenAutoMarketEx "mint" function
  function testOpenAutoMarketExBuyMint() public {
    changePrank(_owner);
    _collection.setDefaultRoyalty(_tester, 100);
    _collection.setMintPrice(1 ether);

    deal(_buyer, 10 ether);
    changePrank(_buyer);
    uint256 tokenID = _collection.mint{value: 1.5 ether}("");
    assertEq(_collection.ownerOf(tokenID), _buyer);
    assertEq(_buyer.balance, 9 ether);
    assertEq(_tester.balance, 0.01 ether);
    assertEq(_owner.balance, 0.981 ether);
    assertEq(makeAddr("treasury").balance, 0.009 ether);
  }

  // Secondary market, token already minted, pay token via OpenAutoMarketEx "buy" function
  function testOpenAutoMarketExBuy2() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);

    changePrank(_owner);
    _collection.setApprovalForAll(_collectionAddress, true);
    _collection.setTokenRoyalty(tokenID, _tester, 100);
    _collection.setTokenPrice(tokenID, 1 ether);

    changePrank(_buyer);
    deal(_buyer, 10 ether);
    uint256 balMinter = _owner.balance;

    assertEq(_collection.ownerOf(tokenID), _owner);
    _collection.buy{value: 1.5 ether}(tokenID);
    assertEq(_collection.ownerOf(tokenID), _buyer);

    assertEq(_buyer.balance, 9 ether);
    assertEq(_collectionAddress.balance, 0 ether);
    assertEq(_tester.balance, 0.01 ether);
    assertEq(_owner.balance, balMinter + 0.981 ether);
    assertEq(makeAddr("treasury").balance, 0.009 ether);
  }

  // Secondary market, token already minted, pay token via ERC721 "safeTransferFrom" function (after approval)
  // can be done by any smartcontract : for example can be used by OpenSea if following ERC2981
  function testOpenAutoMarketExBuyViaSafeTransferFrom() public {
    (uint256 tokenID,) = mintTest(_collectionAddress, _owner);

    changePrank(_owner);
    _collection.setApprovalForAll(address(this), true);
    _collection.setTokenRoyalty(tokenID, _tester, 100);
    _collection.setTokenPrice(tokenID, 1 ether);

    changePrank(_buyer);
    deal(_buyer, 10 ether);
    uint256 balMinter = _owner.balance;
    (bool sent,) = payable(address(this)).call{value: 1.5 ether}("");
    require(sent, "Failed to send Ether");

    changePrank(address(this));
    assertEq(_collection.ownerOf(tokenID), _owner);
    _collection.safeTransferFrom{value: 1.5 ether}(_owner, _buyer, tokenID);
    assertEq(_collection.ownerOf(tokenID), _buyer);

    assertEq(_buyer.balance, 9 ether);
    assertEq(_collectionAddress.balance, 0 ether);
    assertEq(_tester.balance, 0.01 ether);
    assertEq(_owner.balance, balMinter + 0.981 ether);
    assertEq(makeAddr("treasury").balance, 0.009 ether);
  }
}
