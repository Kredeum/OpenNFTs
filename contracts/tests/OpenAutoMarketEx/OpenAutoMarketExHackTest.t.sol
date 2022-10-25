// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/examples/IOpenAutoMarketEx.sol";

contract DumbReceiver {}

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

        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IERC721(_collection).setApprovalForAll(address(this), true);
        IOpenMarketable(_collection).setTokenRoyalty(tokenID, address(dumbReceiver), 100);
        IOpenMarketable(_collection).setTokenPrice(tokenID, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        (bool sent,) = payable(address(this)).call{value: 1.5 ether}("");
        require(sent, "Failed to send Ether");

        changePrank(address(this));

        assertEq(IERC721(_collection).ownerOf(tokenID), _owner);
        IERC721(_collection).safeTransferFrom{value: 1.5 ether}(_owner, _buyer, tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);
    }
}
