// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC173.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";

abstract contract ERC173Test is Test {
  address private _collection;
  string private _tokenURI;
  address private _owner = address(0x1);
  address private _minter = address(0x12);
  address private _tester = address(0x4);
  uint256 private _tokenID0;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function constructorTest(address owner_) public virtual returns (address);

  function setUpERC173() public {
    _collection = constructorTest(_owner);
  }

  function testERC173Owner() public {
    assertEq(IERC173(_collection).owner(), _owner);
  }

  function testERC173TransferOwnership() public {
    vm.prank(_owner);
    IERC173(_collection).transferOwnership(_tester);
    assertEq(IERC173(_collection).owner(), _tester);
  }

  function testFailERC173NotTransferOwnership() public {
    vm.prank(_tester);
    IERC173(_collection).transferOwnership(_minter);
  }

  function testERC173EmitTransferOwnership() public {
    vm.expectEmit(true, true, false, false);
    emit OwnershipTransferred(_owner, _tester);
    vm.prank(_owner);
    IERC173(_collection).transferOwnership(_tester);
  }

  function testERC173SupportsInterface() public {
    assertTrue(IERC165(address(_collection)).supportsInterface(type(IERC173).interfaceId));
  }
}
