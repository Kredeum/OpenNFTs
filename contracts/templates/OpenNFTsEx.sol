// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenNFTs.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTsEx.sol";

/// @title OpenNFTs smartcontract
contract OpenNFTsEx is IOpenNFTsEx, OpenNFTs {
    /// @notice Mint NFT allowed to everyone or only collection owner
    bool public open;

    /// @notice onlyOpenOrOwner, either everybody in open collection,
    /// @notice either only owner in specific collection
    modifier onlyOpenOrOwner() {
        require(open || (owner() == msg.sender), "Not minter");
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        bool[] memory options
    ) external override(IOpenNFTsEx) {
        OpenNFTs.initialize(name_, symbol_, owner_);
        open = options[0];
    }

    function mint(string memory jsonURI)
        external
        override(IOpenNFTsEx)
        onlyOpenOrOwner
        onlyWhenNotPaused
        returns (uint256)
    {
        return _mint(msg.sender, jsonURI);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenNFTs) returns (bool) {
        return interfaceId == type(IOpenNFTsEx).interfaceId || super.supportsInterface(interfaceId);
    }
}
