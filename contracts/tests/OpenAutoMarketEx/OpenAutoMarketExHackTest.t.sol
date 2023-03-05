// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/examples/IOpenAutoMarketEx.sol";

contract DumbReceiver {
    function onERC721Received(address, address, uint256, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}

abstract contract OpenAutoMarketExHackTest is Test {
    address payable private _collection;
    address private _owner = makeAddr("owner");
    address private _minter = makeAddr("minter");
    address private _buyer = makeAddr("buyer");
    address private _tester = makeAddr("tester");
    bool[] private _options = new bool[](2);

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256 tokenID_, string memory tokenURI_);

    function setUpOpenAutoMarketExHack() public {
        _collection = payable(constructorTest(_owner));
    }

    function testOpenAutoMarketExHackTransfer() public {
        DumbReceiver dumbReceiver = new DumbReceiver();
        deal(address(dumbReceiver), 2 ether);
        assertTrue(address(dumbReceiver).balance == 2 ether);

        (uint256 tokenID,) = mintTest(_collection, _owner);
        IOpenMarketable(_collection).setTokenPrice(tokenID, 1 ether);

        changePrank(address(dumbReceiver));
        IOpenAutoMarketEx(_collection).buy{value: 1.5 ether}(tokenID);
        assertTrue(IERC721(_collection).ownerOf(tokenID) == address(dumbReceiver));

        // some ETH stuck in collection smartcontract
        assertTrue(_collection.balance == 0.5 ether);
    }
}
