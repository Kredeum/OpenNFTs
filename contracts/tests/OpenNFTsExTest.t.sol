// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

// import "OpenNFTs/contracts/templates/OpenNFTsEx.sol";
import "./OpenERC721Test.t.sol";
import "./OpenNFTsBurnTest.t.sol";
import "./OpenNFTsBuyTest.t.sol";
import "./OpenNFTsInitializeTest.t.sol";
import "./OpenNFTsSetupTest.t.sol";
import "./ERC173Test.t.sol";
import "./ERC2981Test.t.sol";
import { ERC721TransferableTest } from "./ERC721TransferableTest.t.sol";
import "./OpenPauseableTest.t.sol";
import "./OpenMarketableTest.t.sol";
import "OpenNFTs/contracts/interfaces/ITest.sol";

contract OpenNFTsExTest is
    ITest,
    OpenERC721Test,
    OpenNFTsBurnTest,
    OpenNFTsBuyTest,
    OpenNFTsInitializeTest,
    OpenNFTsSetupTest,
    ERC173Test,
    ERC2981Test,
    ERC721TransferableTest,
    OpenPauseableTest,
    PriceableTest
{
    function constructorTest(address owner)
        public
        override(
            OpenERC721Test,
            OpenNFTsBurnTest,
            OpenNFTsBuyTest,
            OpenNFTsSetupTest,
            ERC173Test,
            ERC721TransferableTest,
            ERC2981Test,
            OpenPauseableTest,
            PriceableTest
        )
        returns (address)
    {
        changePrank(owner);
        bool[] memory options = new bool[](1);
        options[0] = true;

        OpenNFTsEx collection = new OpenNFTsEx();
        collection.initialize("OpenERC721Test", "OPTEST", owner, options);

        return address(collection);
    }

    function mintTest(address collection, address minter)
        public
        override(
            OpenERC721Test,
            OpenNFTsBurnTest,
            OpenNFTsBuyTest,
            OpenNFTsSetupTest,
            ERC2981Test,
            OpenPauseableTest,
            PriceableTest,
            ERC721TransferableTest
        )
        returns (uint256, string memory)
    {
        changePrank(minter);
        return (OpenNFTsEx(collection).mint(_TOKEN_URI), _TOKEN_URI);
    }

    function burnTest(address collection, uint256 tokenID) public override(OpenERC721Test, OpenNFTsBurnTest) {
        changePrank(OpenNFTsEx(collection).ownerOf(tokenID));
        OpenNFTsEx(collection).burn(tokenID);
    }

    function setPriceTest(
        address collection,
        uint256 tokenID,
        uint256 price
    ) public {
        OpenNFTsEx(collection).setTokenPrice(tokenID, price);
    }

    function setRoyaltyTest(
        address collection,
        address receiver,
        uint96 fee
    ) public override(ERC2981Test, PriceableTest) returns (uint256 tokenID) {
        (tokenID, ) = mintTest(collection, receiver);
        OpenNFTsEx(collection).setTokenRoyalty(tokenID, receiver, fee);
    }

    function setUp() public override {
        setUpERC173();
        setUpERC2981();
        setUpPausable();
        setUpPriceable();
        setUpOpenNFTs("OpenERC721Test", "OPTEST");
        setUpERC721Transferable();
        setUpOpenNFTsBurn();
        setUpOpenNFTsBuy();
        setUpOpenNFTsInitialize();
        setUpOpenNFTsSetup();
    }
}
