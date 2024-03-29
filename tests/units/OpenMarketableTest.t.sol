// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";
import "OpenNFTs/contracts/interfaces/IERC173.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";
import "OpenNFTs/contracts/interfaces/IOpenReceiverInfos.sol";

abstract contract OpenMarketableTest is Test, IOpenReceiverInfos {
  address private _collection;
  address private _owner = makeAddr("owner");
  address private _minter = makeAddr("minter");
  address private _tester = makeAddr("tester");
  uint256 private _tokenID0;
  uint256 private _notTokenID = 42;

  uint96 private _maxFee = 10_000;

  // uint256 private maxPrice = uint256(((2**256) - 1)) / _maxFee;

  function constructorTest(address owner_) public virtual returns (address);

  function mintTest(address collection_, address minter_)
    public
    virtual
    returns (uint256, string memory);

  function setRoyaltyTest(address collection_, address receiver_, uint96 fee_)
    public
    virtual
    returns (uint256 tokenID_);

  function setUpMarketable() public {
    _collection = constructorTest(_owner);

    _tokenID0 = setRoyaltyTest(_collection, _owner, 420);
  }

  function testSetDefaultRoyalty(uint96 fee, uint256 price) public {
    vm.assume(price < 2 ** 128);
    vm.assume(fee < 10_000);

    (uint256 tokenID,) = mintTest(_collection, _owner);

    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setDefaultRoyalty(_minter, fee);

    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, price);
    assertEq(receiver, _minter);
    assertEq(royalties, (price * fee) / _maxFee);
  }

  function testSetTokenRoyalty(uint96 fee, uint256 price) public {
    vm.assume(price != 0);
    vm.assume(price < 2 ** 128);
    vm.assume(fee < 10_000);

    assertEq(IERC721(_collection).ownerOf(_tokenID0), _owner);
    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, fee);

    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(_tokenID0, price);
    assertEq(receiver, _tester);
    console.log("testSetTokenRoyalty ~ _maxFee", _maxFee);
    console.log("testSetTokenRoyalty ~ fee", fee);
    console.log("testSetTokenRoyalty ~ price", price);
    console.log("testSetTokenRoyalty ~ royalties", royalties);
    assertEq(royalties, (price * fee) / _maxFee);
  }

  function testFailSetTokenRoyaltyNoToken() public {
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_notTokenID, _tester, 100);
  }

  function testSetTokenPrice(uint256 price) public {
    vm.assume(price < 2 ** 128);

    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, price);
    assertEq(IOpenMarketable(payable(_collection)).getTokenPrice(_tokenID0), price);
  }

  function testSetTokenPriceFromDefault(uint256 price) public {
    vm.assume(price < 2 ** 128);

    assertEq(IOpenMarketable(payable(_collection)).getTokenPrice(_tokenID0), 0);

    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

    assertEq(IOpenMarketable(payable(_collection)).getTokenPrice(_tokenID0), 1 ether);
  }

  function testFailSetMintPriceTooExpensive(uint256 price) public {
    vm.assume(price > 2 ** 128);

    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setMintPrice(price);
  }

  function testFailSetTokenPriceTooExpensive(uint256 price) public {
    vm.assume(price > 2 ** 128);

    vm.prank(_minter);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, price);
  }

  function testFailSetTokenPriceNoToken() public {
    vm.prank(_minter);
    IOpenMarketable(payable(_collection)).setTokenPrice(_notTokenID, 1 ether);
  }

  function testRoyaltyInfoCalculation(uint256 price, uint96 fee) public {
    vm.assume(price < 2 ** 128);
    vm.assume(fee < _maxFee);

    (uint256 tokenID,) = mintTest(_collection, _owner);

    vm.prank(_owner);
    IOpenMarketable(payable(_collection)).setDefaultRoyalty(_minter, fee);

    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, price);
    assertEq(receiver, _minter);

    assertEq(royalties, (price * fee) / _maxFee);
  }

  function testRoyaltyInfoMinimal() public {
    uint256 price = 1 ether;
    uint96 fee = 100;

    vm.startPrank(_owner);
    IOpenMarketable(payable(_collection)).setMintPrice(price);
    IOpenMarketable(payable(_collection)).setDefaultRoyalty(_minter, fee);
    vm.stopPrank();

    (uint256 tokenID,) = mintTest(_collection, _owner);

    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, 0);
    assertEq(receiver, _minter);

    assertEq(royalties, (price * fee) / _maxFee);
  }

  function testRoyaltyInfoMinimal(uint256 mintPrice, uint256 tokenPrice, uint96 fee) public {
    vm.assume(mintPrice < 2 ** 128);
    vm.assume(tokenPrice < 2 ** 128);
    vm.assume(fee < _maxFee);

    vm.startPrank(_owner);
    IOpenMarketable(payable(_collection)).setMintPrice(mintPrice);
    IOpenMarketable(payable(_collection)).setDefaultRoyalty(_minter, fee);
    vm.stopPrank();

    (uint256 tokenID,) = mintTest(_collection, _owner);

    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, tokenPrice);
    assertEq(receiver, _minter);

    uint256 maxPrice = mintPrice > tokenPrice ? mintPrice : tokenPrice;
    assertEq(royalties, (maxPrice * fee) / _maxFee);
  }

  function testTokenOwner() public {
    vm.startPrank(_owner);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);
    vm.stopPrank();
  }

  function testFailTokenOwner() public {
    /// must be collection owner
    vm.prank(_minter);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
  }

  function testFailSetTokenRoyaltyNotOwner() public {
    vm.prank(_tester);
    IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
  }

  function testFailSetTokenPriceNotOwner() public {
    vm.prank(_tester);
    IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);
  }

  function testSupportsInterface() public {
    assertTrue(IERC165(_collection).supportsInterface(type(IOpenMarketable).interfaceId));
  }
}
