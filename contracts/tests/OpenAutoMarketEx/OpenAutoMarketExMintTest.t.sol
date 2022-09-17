// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IAll.sol";
import "OpenNFTs/contracts/examples/IOpenAutoMarketEx.sol";

abstract contract OpenAutoMarketExMintTest is Test {
    address payable private _collection;
    address private _owner = address(0x5);
    address private _minter = address(0x12);
    address private _buyer = address(0x13);
    address private _tester = address(0x4);
    bool[] private _options = new bool[](1);

    receive() external payable {}

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256 tokenID_, string memory tokenURI_);

    function setUpOpenAutoMarketExMint() public {
        _collection = payable(constructorTest(_owner));
    }

    function testOpenAutoMarketExSetDefaultRoyalty() public {
        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IOpenMarketable(_collection).setDefaultRoyalty(_minter, 100);

        (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, 1 ether);

        assertEq(receiver, _minter);
        assertEq(royalties, 0.01 ether);
    }

    function testOpenAutoMarketExSetTokenRoyalty() public {
        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IOpenMarketable(_collection).setTokenRoyalty(tokenID, _owner, 200);
        IOpenMarketable(_collection).setDefaultRoyalty(_minter, 100);

        (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(tokenID, 1 ether);

        assertEq(receiver, _owner);
        assertEq(royalties, 0.02 ether);
    }

    function testOpenAutoMarketExSetDefaultPrice() public {
        changePrank(_owner);
        IOpenMarketable(_collection).setDefaultPrice(1 ether);

        assertEq(IOpenMarketable(_collection).getDefaultPrice(), 1 ether);
    }

    function testOpenAutoMarketExSetTokenPrice() public {
        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IOpenMarketable(_collection).setTokenPrice(tokenID, 2 ether);
        IOpenMarketable(_collection).setDefaultPrice(1 ether);

        assertEq(IOpenMarketable(_collection).getTokenPrice(tokenID), 2 ether);
    }

    // Primary market, token not minted yet, pay token via OpenAutoMarketEx "mint" function
    function testOpenAutoMarketExBuyMint() public {
        changePrank(_owner);
        IOpenMarketable(_collection).setDefaultRoyalty(_tester, 100);
        IOpenMarketable(_collection).setDefaultPrice(1 ether);

        deal(_buyer, 10 ether);
        changePrank(_buyer);
        uint256 tokenID = IOpenAutoMarketEx(_collection).mint{value: 1.5 ether}("");
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);
        assertEq(_buyer.balance, 9 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_owner.balance, 0.981 ether);
        assertEq(makeAddr("treasury").balance, 0.009 ether);
    }

    // Secondary market, token already minted, pay token via OpenAutoMarketEx "buy" function
    function testOpenAutoMarketExBuy() public {
        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IERC721(_collection).setApprovalForAll(_collection, true);
        IOpenMarketable(_collection).setTokenRoyalty(tokenID, _tester, 100);
        IOpenMarketable(_collection).setTokenPrice(tokenID, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        uint256 balMinter = _owner.balance;

        assertEq(IERC721(_collection).ownerOf(tokenID), _owner);
        IOpenAutoMarketEx(_collection).buy{value: 1.5 ether}(tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);

        assertEq(_buyer.balance, 9 ether);
        assertEq(_collection.balance, 0 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_owner.balance, balMinter + 0.981 ether);
        assertEq(makeAddr("treasury").balance, 0.009 ether);
    }

    // Secondary market, token already minted, pay token via ERC721 "safeTransferFrom" function (after approval)
    // can be done by any smartcontract : for example can be used by OpenSea if following ERC2981
    function testOpenAutoMarketExBuyViaSafeTransferFrom() public {
        (uint256 tokenID,) = mintTest(_collection, _owner);

        changePrank(_owner);
        IERC721(_collection).setApprovalForAll(address(this), true);
        IOpenMarketable(_collection).setTokenRoyalty(tokenID, _tester, 100);
        IOpenMarketable(_collection).setTokenPrice(tokenID, 1 ether);

        changePrank(_buyer);
        deal(_buyer, 10 ether);
        uint256 balMinter = _owner.balance;
        (bool sent,) = payable(address(this)).call{value: 1.5 ether}("");
        require(sent, "Failed to send Ether");

        changePrank(address(this));
        assertEq(IERC721(_collection).ownerOf(tokenID), _owner);
        IERC721(_collection).safeTransferFrom{value: 1.5 ether}(_owner, _buyer, tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), _buyer);

        assertEq(_buyer.balance, 9 ether);
        assertEq(_collection.balance, 0 ether);
        assertEq(_tester.balance, 0.01 ether);
        assertEq(_owner.balance, balMinter + 0.981 ether);
        assertEq(makeAddr("treasury").balance, 0.009 ether);
    }
}
