// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "OpenNFTs/contracts/tests/sets/ERC721FullTest.t.sol";
import "OpenNFTs/contracts/tests/units/OpenCheckerTest.t.sol";

abstract contract OpenNFTsTest is ERC721FullTest, OpenCheckerTest {
    function constructorTest(address owner_) public virtual override(ERC721FullTest, OpenCheckerTest) returns (address);

    function mintTest(address collection, address minter_)
        public
        virtual
        override(ERC721FullTest)
        returns (uint256, string memory);

    function burnTest(address collection, uint256 tokenID) public virtual override(ERC721FullTest);

    function setUpOpenNFTs(string memory name_, string memory symbol_) public {
        setUpERC721Full(name_, symbol_);
        setUpOpenChecker();
    }
}
