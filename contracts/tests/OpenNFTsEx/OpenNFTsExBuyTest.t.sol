// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTs.sol";
import "OpenNFTs/contracts/examples/IOpenNFTsEx.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenNFTsExBuyTest is Test {
    address private _collection;
    address private _owner = address(0x4201);
    address private _minter = address(0x4212);
    address private _buyer = address(0x4213);
    address private _tester = address(0x4214);
    uint256 private _tokenID0;

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256, string memory);

    function setUpOpenNFTsBuy() public {
        _collection = constructorTest(_owner);

        (_tokenID0,) = mintTest(_collection, _owner);
    }

    function testBuyOk() public {
        changePrank(_owner);
        IERC721(_collection).setApprovalForAll(_collection, true);

        IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
        IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        uint256 balOwner = _owner.balance;

        assertEq(IERC721(_collection).ownerOf(_tokenID0), _owner);
        IOpenNFTsEx(_collection).buy{value: 1.5 ether}(_tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _buyer);

        // emit log_named_decimal_uint("testBuyOk _buyer.balance", _buyer.balance, 18);

        assertEq(_buyer.balance, 9 ether);
        assertEq(_collection.balance, 0 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_owner.balance, balOwner + 0.99 ether);
    }

    function testFailBuyTwice() public {
        IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
        IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);

        IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
        IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
    }

    function testFailBuyNotEnoughFunds() public {
        IOpenMarketable(payable(_collection)).setTokenRoyalty(_tokenID0, _tester, 100);
        IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);

        IOpenNFTsEx(_collection).buy{value: 0.5 ether}(_tokenID0);
    }

    function testFailBuyNotToSell() public {
        IOpenMarketable(payable(_collection)).setTokenPrice(_tokenID0, 0);

        changePrank(_buyer);
        deal(_buyer, 10 ether);

        assertEq(IERC721(_collection).ownerOf(_tokenID0), _minter);
        IOpenNFTsEx(_collection).buy{value: 1 ether}(_tokenID0);
    }
}
