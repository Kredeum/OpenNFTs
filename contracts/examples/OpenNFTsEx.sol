// SPDX-License-Identifier: MIT
//
// Derived from Kredeum NFTs
// https://github.com/Kredeum/kredeum
//
//       ___           ___         ___           ___                    ___           ___                     ___
//      /  /\         /  /\       /  /\         /__/\                  /__/\         /  /\        ___        /  /\
//     /  /::\       /  /::\     /  /:/_        \  \:\                 \  \:\       /  /:/_      /  /\      /  /:/_
//    /  /:/\:\     /  /:/\:\   /  /:/ /\        \  \:\                 \  \:\     /  /:/ /\    /  /:/     /  /:/ /\
//   /  /:/  \:\   /  /:/~/:/  /  /:/ /:/_   _____\__\:\            _____\__\:\   /  /:/ /:/   /  /:/     /  /:/ /::\
//  /__/:/ \__\:\ /__/:/ /:/  /__/:/ /:/ /\ /__/::::::::\          /__/::::::::\ /__/:/ /:/   /  /::\    /__/:/ /:/\:\
//  \  \:\ /  /:/ \  \:\/:/   \  \:\/:/ /:/ \  \:\~~\~~\/          \  \:\~~\~~\/ \  \:\/:/   /__/:/\:\   \  \:\/:/~/:/
//   \  \:\  /:/   \  \::/     \  \::/ /:/   \  \:\  ~~~            \  \:\  ~~~   \  \::/    \__\/  \:\   \  \::/ /:/
//    \  \:\/:/     \  \:\      \  \:\/:/     \  \:\                 \  \:\        \  \:\         \  \:\   \__\/ /:/
//     \  \::/       \  \:\      \  \::/       \  \:\                 \  \:\        \  \:\         \__\/     /__/:/
//      \__\/         \__\/       \__\/         \__\/                  \__\/         \__\/                   \__\/
//
//
//   OpenERC165
//   (supports)
//       |
//       ———————————————————————————————————————————————————————————————————————————————————————
//       |                                                         |             |             |
//   OpenERC721                                               OpenERC173  OpenChecker  OpenCloneable
//     (NFT)                                                   (ownable)         |             |
//       |                                                         |             |             |
//       —————————————————————————————————————————————      ————————             |             |
//       |                        |                  |      |      |             |             |
//  OpenERC721Metadata  OpenERC721Enumerable   OpenERC2981  |      |             |             |
//       |                        |           (RoyaltyInfo) |      |             |             |
//       |                        |                  |      |      |             |             |
//       |                        |                  ————————      |             |             |
//       |                        |                  |             |             |             |
//       |                        |            OpenMarketable OpenPauseable      |             |
//       |                        |                  |             |             |             |
//       ———————————————————————————————————————————————————————————————————————————————————————
//       |
//    OpenNFTs
//       |
//   OpenNFTsEx —— IOpenNFTsEx
//
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/OpenNFTs/OpenNFTs.sol";
import "OpenNFTs/contracts/examples/IOpenNFTsEx.sol";

/// @title OpenNFTs smartcontract
contract OpenNFTsEx is IOpenNFTsEx, OpenNFTs {
    /// @notice Mint NFT allowed to everyone or only collection owner
    bool public open;

    /// @notice override onlyMinter:
    /// @notice either everybody in open collection,
    /// @notice either only owner in specific collection
    modifier onlyMinter() override (OpenNFTs) {
        require(open || (owner() == msg.sender), "Not minter");
        _;
    }

    function buy(uint256 tokenID) external payable override (IOpenNFTsEx) {
        this.safeTransferFrom{value: msg.value}(ownerOf(tokenID), msg.sender, tokenID);
    }

    function initialize(string memory name_, string memory symbol_, address owner_, bool[] memory options)
        external
        override (IOpenNFTsEx)
    {
        OpenNFTs._initialize(name_, symbol_, owner_);
        open = options[0];
    }

    function mint(string memory tokenURI)
        external
        override (IOpenNFTsEx)
        onlyMinter
        onlyWhenNotPaused
        returns (uint256)
    {
        return OpenNFTs.mint(msg.sender, tokenURI);
    }

    function supportsInterface(bytes4 interfaceId) public view override (OpenNFTs) returns (bool) {
        return interfaceId == type(IOpenNFTsEx).interfaceId || super.supportsInterface(interfaceId);
    }
}