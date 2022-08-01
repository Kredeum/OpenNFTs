// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/interfaces/IOpenAutoMarket.sol";

abstract contract OpenAutoMarketMintTest is Test {
    address private _collection;
    address private _owner = address(0x1);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](1);

    uint96 private _maxFee = 10000;
    uint96 private _fee = 200; // 2%
    uint256 private _price = 1 ether;

    receive() external payable {}

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256 tokenID_, string memory tokenURI_);

    function setUpOpenAutoMarketMint() public {
        _collection = constructorTest(_owner);
    }

    function testOpenAutoMarketSetDefaultRoyaltyt() public {
        (uint256 tokenID, ) = mintTest(_collection, _owner);

        changePrank(_owner);
        IOpenMarketable(payable(_collection)).setDefaultRoyalty(_minter, _fee);

        (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, _price);
        assertEq(receiver, _minter);
        assertEq(royalties, (_price * _fee) / _maxFee);
    }

    // Primary market, token not minted yet, pay token via OpenAutoMarket "mint" function
    function testOpenAutoMarketBuyMint() public {
        // changePrank(_owner);
        // IOpenMarketable(payable(_collection)).setDefaultRoyalty(_tester, 100);
        // IOpenMarketable(payable(_collection)).setDefaultPrice(1 ether);
        // (uint256 tokenID, ) = mintTest(_collection, _minter);
    }

    // Secondary market, token already minted, pay token via OpenAutoMarket "buy" function
    function testOpenAutoMarketBuy() public {
        (uint256 tokenID, ) = mintTest(_collection, _minter);

        changePrank(_minter);
        IERC721(_collection).setApprovalForAll(_collection, true);
        IOpenMarketable(payable(_collection)).setTokenRoyalty(tokenID, _tester, 100);
        IOpenMarketable(payable(_collection)).setTokenPrice(tokenID, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        uint256 balMinter = _minter.balance;

        assertEq(IERC721(_collection).ownerOf(tokenID), _minter);
        IOpenAutoMarket(_collection).buy{ value: 1.5 ether }(tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);

        assertEq(_buyer.balance, 9 ether);
        assertEq(_collection.balance, 0 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_minter.balance, balMinter + 0.99 ether);
    }

    // Secondary market, token already minted, pay token via ERC721 "safeTransferFrom" function (after approval)
    // can be done by any smartcontract : for example can be used by OpenSea if following ERC2981
    function testOpenAutoMarketBuyViaSafeTransferFrom() public {
        (uint256 tokenID, ) = mintTest(_collection, _minter);

        changePrank(_minter);
        IERC721(_collection).setApprovalForAll(address(this), true);
        IOpenMarketable(payable(_collection)).setTokenRoyalty(tokenID, _tester, 100);
        IOpenMarketable(payable(_collection)).setTokenPrice(tokenID, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        uint256 balMinter = _minter.balance;
        (bool sent, ) = payable(address(this)).call{ value: 1.5 ether }("");
        require(sent, "Failed to send Ether");

        changePrank(address(this));
        assertEq(IERC721(_collection).ownerOf(tokenID), _minter);
        IERC721(_collection).safeTransferFrom{ value: 1.5 ether }(_minter, _buyer, tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);

        assertEq(_buyer.balance, 9 ether);
        assertEq(_collection.balance, 0 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_minter.balance, balMinter + 0.99 ether);
    }
}
