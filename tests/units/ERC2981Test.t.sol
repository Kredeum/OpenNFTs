// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC2981.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract ERC2981Test is Test {
  address private _collection;
  address private _owner = address(0x1);
  address private _minter = address(0x12);
  uint256 private _tokenID0;

  function constructorTest(address owner_) public virtual returns (address contract_);

  function mintTest(address collection_, address minter_)
    public
    virtual
    returns (uint256, string memory);

  function setRoyaltyTest(address collection_, address receiver_, uint96 fee_)
    public
    virtual
    returns (uint256 tokenID_);

  function setUpERC2981() public {
    _collection = constructorTest(_owner);

    _tokenID0 = setRoyaltyTest(_collection, _minter, 420);
  }

  function testERC2981RoyaltyInfo(uint256 price) public {
    vm.assume(price < 2 ** 128);
    (address receiver, uint256 royalty) = IERC2981(_collection).royaltyInfo(_tokenID0, price);

    assertEq(receiver, _minter);
    assertEq(royalty, (price * 420) / 10_000);
  }

  function testFailERC2981RoyaltyInfoTooExpensive(uint256 price) public view {
    vm.assume(price >= 2 ** 128);
    IERC2981(_collection).royaltyInfo(_tokenID0, price);
  }

  function testERC2981SupportsInterface() public {
    assertTrue(IERC165(_collection).supportsInterface(type(IERC2981).interfaceId));
  }
}
