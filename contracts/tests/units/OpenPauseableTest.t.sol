// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC173.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenPauseable.sol";

abstract contract OpenPauseableTest is Test {
    address private _collection;
    address private _owner = address(0x1);
    address private _tester = address(0x4);

    event SetPaused(bool indexed paused, address indexed account);

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256, string memory);

    function setUpPausable() public {
        _collection = constructorTest(_owner);
    }

    function testPausable() public {
        assertEq(IOpenPauseable(_collection).paused(), false);
    }

    function testPausableTogglePause() public {
        changePrank(_owner);

        IOpenPauseable(_collection).togglePause();
        assertEq(IOpenPauseable(_collection).paused(), true);

        IOpenPauseable(_collection).togglePause();
        assertEq(IOpenPauseable(_collection).paused(), false);
    }

    function testFailPausableTogglePauseNotOwner() public {
        changePrank(_tester);
        IOpenPauseable(_collection).togglePause();
    }

    function testFailPausableOnlyWhenNotPaused() public {
        changePrank(_owner);
        IOpenPauseable(_collection).togglePause();
        assertEq(IOpenPauseable(_collection).paused(), true);

        mintTest(_collection, _owner);
    }

    function testPausableEmitSetPause() public {
        changePrank(_owner);

        vm.expectEmit(true, true, false, false);
        emit SetPaused(true, _owner);
        IOpenPauseable(_collection).togglePause();

        vm.expectEmit(true, true, false, false);
        emit SetPaused(false, _owner);
        IOpenPauseable(_collection).togglePause();
    }

    function testPausableSupportsInterface() public {
        assertTrue(IERC165(_collection).supportsInterface(type(IOpenPauseable).interfaceId));
    }
}
