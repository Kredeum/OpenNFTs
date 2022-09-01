// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/examples/OpenBoundEx.sol";
import "OpenNFTs/contracts/tests/OpenBoundEx/OpenBoundExSupportsTest.t.sol";

import "OpenNFTs/contracts/tests/sets/OpenNFTsTest.t.sol";
import "OpenNFTs/contracts/tests/units/ERC173Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721NonTransferableTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenPauseableTest.t.sol";

contract OpenBoundExTest is
    OpenNFTsTest,
    ERC173Test,
    ERC721NonTransferableTest,
    OpenPauseableTest,
    OpenBoundExSupportsTest
{
    uint256 private _cid = 777;

    function constructorTest(address owner)
        public
        override(OpenNFTsTest, ERC173Test, ERC721NonTransferableTest, OpenPauseableTest, OpenBoundExSupportsTest)
        returns (address)
    {
        changePrank(owner);
        bool[] memory options = new bool[](1);
        options[0] = true;

        OpenBoundEx collection = new OpenBoundEx();
        collection.initialize("OpenBoundEx", "BOUND", owner, 0);

        return address(collection);
    }

    function mintTest(address collection, address minter)
        public
        override(OpenNFTsTest, OpenPauseableTest, ERC721NonTransferableTest)
        returns (uint256, string memory)
    {
        changePrank(minter);
        uint256 tokenID = OpenBoundEx(payable(collection)).mint(_cid++);
        string memory tokenURI = OpenBoundEx(payable(collection)).tokenURI(tokenID);
        return (tokenID, tokenURI);
    }

    function burnTest(address collection, uint256 tokenID) public override(OpenNFTsTest, ERC721NonTransferableTest) {
        changePrank(OpenBoundEx(payable(collection)).ownerOf(tokenID));
        OpenBoundEx(payable(collection)).burn(tokenID);
    }

    function setUp() public {
        setUpERC173();
        setUpPausable();
        setUpOpenNFTs("OpenBoundEx", "BOUND");
        setUpERC721NonTransferable();
        setUpOpenBoundExSupports();
    }
}
