// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/tests/interfaces/IAll.sol";
import "OpenNFTs/tests/interfaces/IOpenBoundEx.sol";
import "OpenNFTs/tests/examples/OpenResolverEx.sol";

abstract contract OpenBoundExSupportsTest is Test {
  OpenResolverEx private _resolver;
  address private _collection;
  address private _owner = address(0x1);
  address private _minter = address(0x12);
  address private _buyer = address(0x13);
  address private _tester = address(0x4);
  bool[] private _options = new bool[](2);

  function constructorTest(address owner_) public virtual returns (address);

  function setUpOpenBoundExSupports() public {
    _collection = constructorTest(_owner);

    _resolver = new OpenResolverEx();
  }

  function testOpenBoundExCheckErcInterfaces() public {
    bool[11] memory expected =
      [false, true, true, true, true, false, false, false, false, true, false];

    bool[] memory checks = IOpenChecker(_resolver).checkErcInterfaces(_collection);

    for (uint256 i = 0; i < expected.length; i++) {
      assertEq(checks[i], expected[i]);
    }
  }

  function testOpenBoundExCheckSupportedInterfaces() public {
    bytes4[5] memory ids = [
      type(IOpenChecker).interfaceId,
      type(IOpenPauseable).interfaceId,
      type(IOpenCloneable).interfaceId,
      type(IOpenBoundEx).interfaceId,
      type(IOpenMarketable).interfaceId
    ];
    bool[5] memory expected = [true, true, true, true, false];

    bytes4[] memory interfaceIds = new bytes4[](5);
    for (uint256 i = 0; i < ids.length; i++) {
      interfaceIds[i] = ids[i];
    }

    bool[] memory checks =
      IOpenChecker(_resolver).checkSupportedInterfaces(_collection, false, interfaceIds);

    for (uint256 i = 0; i < ids.length; i++) {
      assertEq(checks[i], expected[i]);
    }
  }
}
