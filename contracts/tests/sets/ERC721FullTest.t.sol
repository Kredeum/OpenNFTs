// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "OpenNFTs/contracts/tests/units/ERC165Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721Test.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721MetadataTest.t.sol";
import "OpenNFTs/contracts/tests/units/ERC721EnumerableTest.t.sol";

abstract contract ERC721FullTest is
    ERC165Test,
    ERC721Test,
    ERC721MetadataTest,
    ERC721EnumerableTest
{
    string internal constant _TOKEN_URI =
        "ipfs://bafkreidfhassyaujwpbarjwtrc6vgn2iwfjmukw3v7hvgggvwlvdngzllm";
    bool private _transferable = true;

    function constructorTest(address owner_)
        public
        virtual
        override (ERC165Test, ERC721Test, ERC721MetadataTest, ERC721EnumerableTest)
        returns (address);

    function mintTest(address collection, address minter_)
        public
        virtual
        override (ERC721Test, ERC721MetadataTest, ERC721EnumerableTest)
        returns (uint256, string memory);

    function burnTest(address collection, uint256 tokenID) public virtual override (ERC721Test);

    function setUpERC721Full(string memory name_, string memory symbol_) public {
        // setUpERC165();
        setUpERC165();
        setUpERC721();
        setUpERC721Metadata(name_, symbol_);
        setUpERC721Enumerable();
    }
}
