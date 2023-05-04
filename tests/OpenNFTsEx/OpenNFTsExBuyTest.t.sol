// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTs.sol";
import "OpenNFTs/tests/interfaces/IOpenNFTsEx.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenNFTsExBuyTest is Test {
  address private _collection;
  address private _owner = address(0x4201);
  address private _minter = address(0x4212);
  address private _buyer = address(0x4213);
  address private _tester = address(0x4214);
  uint256 private _tokenID0;

  function constructorTest(address owner_) public virtual returns (address);

  function mintTest(address collection_, address minter_)
    public
    virtual
    returns (uint256, string memory);

  function setUpOpenNFTsBuy() public {
    _collection = constructorTest(_owner);

    (_tokenID0,) = mintTest(_collection, _owner);
  }

  function testBuyOk2(uint256 amount) public {
    vm.assume(amount < 10 * 36);

    vm.startPrank(_owner);
    IERC721(_collection).setApprovalForAll(_collection, true);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, amount);
    vm.stopPrank();

    deal(_buyer, amount);

    assertEq(IERC721(_collection).ownerOf(_tokenID0), _owner);
    vm.prank(_buyer);
    IOpenNFTsEx(_collection).buy{value: amount}(_tokenID0);
    assertEq(IERC721(_collection).ownerOf(_tokenID0), _buyer);
  }

  function testBuyOk() public {
    vm.startPrank(_owner);
    IERC721(_collection).setApprovalForAll(_collection, true);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);
    vm.stopPrank();

    deal(_buyer, 10 ether);
    uint256 balOwner = _owner.balance;

    assertEq(IERC721(_collection).ownerOf(_tokenID0), _owner);
    vm.prank(_buyer);
    IOpenNFTsEx(_collection).buy{value: 1.5 ether}(_tokenID0);
    assertEq(IERC721(_collection).ownerOf(_tokenID0), _buyer);

    // emit log_named_decimal_uint("testBuyOk _buyer.balance", _buyer.balance, 18);

    assertEq(_buyer.balance, 9 ether);
    assertEq(_collection.balance, 0 ether);
    assertEq(_tester.balance, 0.01 ether);
    assertEq(_owner.balance, balOwner + 0.99 ether);
  }

  function testFailBuyTwice() public {
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

    deal(_buyer, 10 ether);

    vm.startPrank(_buyer);
    IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
    IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
    vm.stopPrank();
  }

  function testFailBuyNotEnoughFunds() public {
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

    deal(_buyer, 10 ether);

    vm.prank(_buyer);
    IOpenNFTsEx(_collection).buy{value: 0.5 ether}(_tokenID0);
  }

  function testFailBuyNotToSell() public {
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 0);

    deal(_buyer, 10 ether);

    assertEq(IERC721(_collection).ownerOf(_tokenID0), _minter);
    vm.prank(_buyer);
    IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
  }
}
