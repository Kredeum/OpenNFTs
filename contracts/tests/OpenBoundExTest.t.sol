// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "../../lib/forge-std/src/Test.sol";

import "OpenNFTs/contracts/templates/OpenBoundEx.sol";
import "OpenNFTs/contracts/interfaces/ITest.sol";
import {OpenERC721Test} from "./OpenERC721Test.t.sol";
import {ERC173Test} from "./ERC173Test.t.sol";
import {ERC721NonTransferableTest} from "./ERC721NonTransferableTest.t.sol";
import {OpenPauseableTest} from "./OpenPauseableTest.t.sol";

contract OpenBoundTest is
    ITest,
    OpenERC721Test,
    ERC173Test,
    ERC721NonTransferableTest,
    OpenPauseableTest
{
    uint256 private _cid = 777;

    function constructorTest(address owner)
        public
        override(
            OpenERC721Test,
            ERC173Test,
            ERC721NonTransferableTest,
            OpenPauseableTest
        )
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
        override(OpenERC721Test, OpenPauseableTest, ERC721NonTransferableTest)
        returns (uint256, string memory)
    {
        changePrank(minter);
        uint256 tokenID = OpenBoundEx(collection).mint(_cid++);
        string memory tokenURI = OpenBoundEx(collection).tokenURI(tokenID);
        return (tokenID, tokenURI);
    }

    function burnTest(address collection, uint256 tokenID)
        public
        override(OpenERC721Test, ERC721NonTransferableTest)
    {
        changePrank(OpenBoundEx(collection).ownerOf(tokenID));
        OpenBoundEx(collection).burn(tokenID);
    }

    function setUp() public override {
        setUpERC173();
        setUpPausable();
        setUpOpenNFTs("OpenBoundEx", "BOUND");
        setUpERC721NonTransferable();
    }
}
