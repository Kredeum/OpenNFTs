// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/templates/OpenResolverEx.sol";

import "OpenNFTs/contracts/interfaces/ITest.sol";
import "OpenNFTs/contracts/tests/units/OpenResolverTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenCheckerTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenGetterTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenRegistryTest.t.sol";

contract OpenResolverExTest is ITest, OpenResolverTest, OpenCheckerTest, OpenGetterTest, OpenRegistryTest {
    function constructorTest(address owner)
        public
        override (OpenResolverTest, OpenGetterTest, OpenCheckerTest, OpenRegistryTest)
        returns (address)
    {
        changePrank(owner);

        OpenResolverEx collection = new OpenResolverEx();
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
