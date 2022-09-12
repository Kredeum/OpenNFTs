// SPDX-License-Identifier: MITs
//
//   OpenERC165
//   (supports)
//        |
//        ————————————————————————————
//        |            |             |
//   OpenERC721    OpenERC173   OpenERC2981
//      (NFT)      (Ownable)   (RoyaltyInfo)
//        |            |             |
//        ————————————————————————————
//        |
//  OpenMarketable —— IOpenMarketable
//
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/examples/OpenAutoMarketEx.sol";
import "OpenNFTs/contracts/tests/OpenAutoMarketEx/OpenAutoMarketExMintTest.t.sol";

import "OpenNFTs/contracts/tests/units/ERC165Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC173Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721TransferableTest.t.sol";
import "OpenNFTs/contracts/tests/units/ERC2981Test.t.sol";
import "OpenNFTs/contracts/tests/units/OpenMarketableTest.t.sol";

import "OpenNFTs/contracts/interfaces/ITest.sol";

contract OpenAutoMarketExTest is
    ITest,
    ERC165Test,
    ERC173Test,
    ERC721Test,
    ERC721TransferableTest,
    ERC2981Test,
    OpenMarketableTest,
    OpenAutoMarketExMintTest
{
    string private constant _TOKEN_URI =
        "ipfs://bafkreidfhassyaujwpbarjwtrc6vgn2iwfjmukw3v7hvgggvwlvdngzllm";

    function constructorTest(address owner)
        public
        override (
            ERC165Test,
            ERC173Test,
            ERC721Test,
            ERC721TransferableTest,
            ERC2981Test,
            OpenMarketableTest,
            OpenAutoMarketExMintTest
        )
        returns (address)
    {
        changePrank(owner);
        OpenAutoMarketEx collection = new OpenAutoMarketEx();
        collection.initialize(owner);
        return address(collection);
    }

    function mintTest(address collection, address minter)
        public
        override (
            ERC721Test,
            ERC721TransferableTest,
            ERC2981Test,
            OpenMarketableTest,
            OpenAutoMarketExMintTest
        )
        returns (uint256 tokenID, string memory tokenURI)
    {
        changePrank(minter);
        tokenURI = _TOKEN_URI;
        tokenID = OpenAutoMarketEx(payable(collection)).mint(tokenURI);
    }

    function burnTest(address collection, uint256 tokenID) public override (ERC721Test) {
        changePrank(OpenAutoMarketEx(payable(collection)).ownerOf(tokenID));
        OpenAutoMarketEx(payable(collection)).burn(tokenID);
    }

    function setPriceTest(address collection, uint256 tokenID, uint256 price) public {
        OpenAutoMarketEx(payable(collection)).setTokenPrice(tokenID, price);
    }

    function setRoyaltyTest(address collection, address receiver, uint96 fee)
        public
        override (ERC2981Test, OpenMarketableTest)
        returns (uint256 tokenID)
    {
        changePrank(OpenAutoMarketEx(payable(collection)).owner());
        (tokenID,) = (OpenAutoMarketEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
        OpenAutoMarketEx(payable(collection)).setTokenRoyalty(tokenID, receiver, fee);
    }

    function setUp() public override (ITest) {
        setUpERC165();
        setUpERC721();
        setUpERC173();
        setUpERC2981();
        setUpMarketable();
        setUpERC721Transferable();
        setUpOpenAutoMarketExMint();
    }
}
