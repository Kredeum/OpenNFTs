// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/examples/OpenNFTsEx.sol";
import "OpenNFTs/contracts/examples/OpenClonerEx.sol";

abstract contract OpenNFTsExCloneTest is Test {
    OpenClonerEx private _cloner;
    address private _collection;
    address private _owner = address(0x1);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](1);

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenNFTsExClone() public {
        _collection = constructorTest(_owner);
        _cloner = new OpenClonerEx();
    }

    function testOpenNFTsExClone() public {
        address clone = _cloner.clone(address(_collection));
        assertEq(OpenNFTsEx(payable(clone)).name(), "Cloned by OpenClonerEx");
    }
}
