// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/ITest.sol";
import "OpenNFTs/contracts/interfaces/IOpenCloneable.sol";
import "OpenNFTs/contracts/examples/OpenClonerEx.sol";
import "OpenNFTs/contracts/examples/OpenNFTsEx.sol";

contract OpenClonerExTest is Test {
    OpenNFTsEx private _collection;
    OpenClonerEx private _cloner;
    address private _owner = address(0x5);

    function setUp() public {
        bool[] memory options = new bool[](2);
        options[0] = true;

        _collection = new OpenNFTsEx();
        _collection.initialize(
            "OpenERC721Test", "OPTEST", _owner, payable(address(0x7)), 0, options
        );

        _cloner = new OpenClonerEx();
    }

    function testOne() public {
        changePrank(_owner);

        address clone = _cloner.clone(address(_collection));
        address parent = IOpenCloneable(clone).parent();
        assertEq(parent, address(_collection));

        uint256 len = clone.code.length;
        assertEq(len, 45);

        console.log("      _collection.address", address(_collection));
        emit log_named_bytes("code", clone.code);

        bytes memory c1 = hex"363d3d373d3d3d363d73";
        bytes memory c2 = abi.encodePacked(address(_collection));
        bytes memory c3 = hex"5af43d82803e903d91602b57fd5bf3";
        assertEq0(clone.code, bytes.concat(c1, c2, c3));
    }
}
