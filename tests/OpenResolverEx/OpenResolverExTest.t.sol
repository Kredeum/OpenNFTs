// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/tests/examples/OpenResolverEx.sol";

import "OpenNFTs/tests/interfaces/ITest.sol";
import "OpenNFTs/tests/units/OpenResolverTest.t.sol";
import "OpenNFTs/tests/units/OpenCheckerTest.t.sol";
import "OpenNFTs/tests/units/OpenGetterTest.t.sol";
import "OpenNFTs/tests/units/OpenRegistryTest.t.sol";

contract OpenResolverExTest is
  ITest,
  OpenResolverTest,
  OpenCheckerTest,
  OpenGetterTest,
  OpenRegistryTest
{
  function constructorTest(address owner)
    public
    override(OpenResolverTest, OpenGetterTest, OpenCheckerTest, OpenRegistryTest)
    returns (address)
  {
    OpenResolverEx collection = new OpenResolverEx();

    vm.prank(owner);
    collection.initialize(owner, owner);

    return address(collection);
  }

  function setUp() public override {
    setUpOpenResolver();
    setUpOpenRegistry();
    setUpOpenChecker();
    setUpOpenGetter();
  }
}
