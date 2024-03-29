// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";

abstract contract ERC165Test is Test {
  address private _collection;
  address private _owner = address(0x1);

  function constructorTest(address owner_) public virtual returns (address);

  function setUpERC165() public {
    _collection = constructorTest(_owner);
  }

  function testERC165SupportsInterface() public {
    assertTrue(IERC165(_collection).supportsInterface(type(IERC165).interfaceId));
    assertFalse(IERC165(_collection).supportsInterface(0xffffffff));
  }
}
