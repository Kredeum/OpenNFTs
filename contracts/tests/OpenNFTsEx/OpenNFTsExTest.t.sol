// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/examples/OpenNFTsEx.sol";

import "OpenNFTs/contracts/tests/OpenNFTsEx/OpenNFTsExInitializeTest.t.sol";
import "OpenNFTs/contracts/tests/OpenNFTsEx/OpenNFTsExSupportsTest.t.sol";
import "OpenNFTs/contracts/tests/OpenNFTsEx/OpenNFTsExBuyTest.t.sol";

import "OpenNFTs/contracts/tests/sets/OpenNFTsTest.t.sol";

import "OpenNFTs/contracts/tests/units/ERC721TransferableTest.t.sol";
import "OpenNFTs/contracts/tests/units/ERC173Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC2981Test.t.sol";
import "OpenNFTs/contracts/tests/units/OpenNFTsBurnTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenNFTsSetupTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenPauseableTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenMarketableTest.t.sol";

contract OpenNFTsExTest is
    ERC721TransferableTest,
    ERC173Test,
    ERC2981Test,
    OpenNFTsExInitializeTest,
    OpenNFTsExSupportsTest,
    OpenNFTsExBuyTest,
    OpenNFTsTest,
    OpenNFTsBurnTest,
    OpenNFTsSetupTest,
    OpenPauseableTest,
    OpenMarketableTest
{
    function constructorTest(address owner)
        public
        override (
            ERC721TransferableTest,
            ERC173Test,
            ERC2981Test,
            OpenNFTsTest,
            OpenNFTsExSupportsTest,
            OpenNFTsExBuyTest,
            OpenNFTsBurnTest,
            OpenNFTsSetupTest,
            OpenPauseableTest,
            OpenMarketableTest
        )
        returns (address)
    {
        return constructorTest(owner, true);
    }

    function constructorTest(address owner, bool init)
        public
        override (OpenNFTsExInitializeTest)
        returns (address)
    {
        changePrank(owner);
        bool[] memory options = new bool[](1);
        options[0] = true;

        OpenNFTsEx collection = new OpenNFTsEx();
        if (init) {
            collection.initialize("OpenERC721Test", "OPTEST", owner, options);
        }

        return address(collection);
    }

    function mintTest(address collection, address minter)
        public
        override (
            OpenNFTsExBuyTest,
            OpenNFTsTest,
            OpenNFTsBurnTest,
            OpenNFTsSetupTest,
            ERC2981Test,
            OpenPauseableTest,
            OpenMarketableTest,
            ERC721TransferableTest
        )
        returns (uint256, string memory)
    {
        changePrank(minter);
        return (OpenNFTsEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
    }

    function burnTest(address collection, uint256 tokenID)
        public
        override (OpenNFTsTest, OpenNFTsBurnTest)
    {
        changePrank(OpenNFTsEx(payable(collection)).ownerOf(tokenID));
        OpenNFTsEx(payable(collection)).burn(tokenID);
    }

    function setPriceTest(address collection, uint256 tokenID, uint256 price) public {
        OpenNFTsEx(payable(collection)).setTokenPrice(tokenID, price);
    }

    function setRoyaltyTest(address collection, address receiver, uint96 fee)
        public
        override (ERC2981Test, OpenMarketableTest)
        returns (uint256 tokenID)
    {
        changePrank(OpenNFTsEx(payable(collection)).owner());
        (tokenID,) = (OpenNFTsEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
        OpenNFTsEx(payable(collection)).setTokenRoyalty(tokenID, receiver, fee);
    }

    function setUp() public {
        setUpERC173();
        setUpERC2981();
        setUpPausable();
        setUpMarketable();
        setUpOpenNFTs("OpenERC721Test", "OPTEST");
        setUpERC721Transferable();
        setUpOpenNFTsBurn();
        setUpOpenNFTsBuy();
        setUpOpenNFTsSetup();
        setUpOpenNFTsExInitialize();
        setUpOpenNFTsExSupports();
    }
}
