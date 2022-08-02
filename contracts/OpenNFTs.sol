// SPDX-License-Identifier: MIT
//
// Derived from Kredeum NFTs
// https://github.com/Kredeum/kredeum
//
//       ___           ___         ___           ___              ___           ___                     ___
//      /  /\         /  /\       /  /\         /__/\            /__/\         /  /\        ___        /  /\
//     /  /::\       /  /::\     /  /:/_        \  \:\           \  \:\       /  /:/_      /  /\      /  /:/_
//    /  /:/\:\     /  /:/\:\   /  /:/ /\        \  \:\           \  \:\     /  /:/ /\    /  /:/     /  /:/ /\
//   /  /:/  \:\   /  /:/~/:/  /  /:/ /:/_   _____\__\:\      _____\__\:\   /  /:/ /:/   /  /:/     /  /:/ /::\
//  /__/:/ \__\:\ /__/:/ /:/  /__/:/ /:/ /\ /__/::::::::\    /__/::::::::\ /__/:/ /:/   /  /::\    /__/:/ /:/\:\
//  \  \:\ /  /:/ \  \:\/:/   \  \:\/:/ /:/ \  \:\~~\~~\/    \  \:\~~\~~\/ \  \:\/:/   /__/:/\:\   \  \:\/:/~/:/
//   \  \:\  /:/   \  \::/     \  \::/ /:/   \  \:\  ~~~      \  \:\  ~~~   \  \::/    \__\/  \:\   \  \::/ /:/
//    \  \:\/:/     \  \:\      \  \:\/:/     \  \:\           \  \:\        \  \:\         \  \:\   \__\/ /:/
//     \  \::/       \  \:\      \  \::/       \  \:\           \  \:\        \  \:\         \__\/     /__/:/
//      \__\/         \__\/       \__\/         \__\/            \__\/         \__\/                   \__\/
//
//   OpenERC165
//   (supports)
//       |
//       ———————————————————————————————————————————————————————————————————————————————————
//       |                                       |             |             |             |
//   OpenERC721                            OpenERC2981    OpenERC173  OpenCheckable  OpenCloneable
//     (NFT)                              (RoyaltyInfo)    (ownable)         |             |
//       |                                        |            |             |             |
//       ——————————————————————————————————————   |     ————————             |             |
//       |                        |           |   |     |      |             |             |
//  OpenERC721Metadata  OpenERC721Enumerable  |   ———————      |             |             |
//       |                        |           |   |            |             |             |
//       |                        |      OpenMarketable   OpenPauseable      |             |
//       |                        |             |              |             |             |
//       ———————————————————————————————————————————————————————————————————————————————————
//       |
//    OpenNFTs —— IOpenNFTs
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC20.sol";
import "OpenNFTs/contracts/interfaces/IOpenNFTs.sol";

import "OpenNFTs/contracts/OpenERC721Metadata.sol";
import "OpenNFTs/contracts/OpenERC721Enumerable.sol";
import "OpenNFTs/contracts/OpenMarketable.sol";
import "OpenNFTs/contracts/OpenPauseable.sol";
import "OpenNFTs/contracts/OpenCheckable.sol";
import "OpenNFTs/contracts/OpenCloneable.sol";

/// @title OpenNFTs smartcontract
contract OpenNFTs is
    IOpenNFTs,
    OpenERC721Metadata,
    OpenERC721Enumerable,
    OpenMarketable,
    OpenPauseable,
    OpenCheckable,
    OpenCloneable
{
    /// @notice tokenID of next minted NFT
    uint256 public tokenIdNext = 1;

    /// @notice burn NFT
    /// @param tokenID tokenID of NFT to burn
    function burn(uint256 tokenID) external override(IOpenNFTs) onlyTokenOwnerOrApproved(tokenID) {
        _burn(tokenID);
    }

    /// @notice withdraw token otherwise eth
    function withdraw(address token) external override(IOpenNFTs) onlyOwner {
        if ((token.code.length != 0) && (IERC165(token).supportsInterface(type(IERC20).interfaceId))) {
            require(IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this))), "Withdraw failed");
        } else {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function mint(address minter, string memory tokenURI) public override(IOpenNFTs) returns (uint256 tokenID) {
        tokenID = tokenIdNext++;
        _mint(minter, tokenURI, tokenID);
    }

    /// @notice initialize
    /// @param name_ name of the NFT Collection
    /// @param symbol_ symbol of the NFT Collection
    /// @param owner_ owner of the NFT Collection
    // solhint-disable-next-line comprehensive-interface
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_
    ) public {
        OpenCloneable._initialize("OpenNFTs", 4);
        OpenERC721Metadata._initialize(name_, symbol_);
        OpenERC173._initialize(owner_);
    }

    /// @notice test if this interface is supported
    /// @param interfaceId interfaceId to test
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(OpenMarketable, OpenERC721Metadata, OpenERC721Enumerable, OpenCloneable, OpenPauseable, OpenCheckable)
        returns (bool)
    {
        return interfaceId == type(IOpenNFTs).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice _mint
    /// @param minter address of minter
    /// @param tokenURI json URI of NFT metadata
    function _mint(
        address minter,
        string memory tokenURI,
        uint256 tokenID
    ) internal override(OpenERC721Enumerable, OpenERC721Metadata, OpenMarketable) {
        super._mint(minter, tokenURI, tokenID);
    }

    function _burn(uint256 tokenID) internal override(OpenERC721Enumerable, OpenERC721Metadata, OpenMarketable) {
        super._burn(tokenID);
    }

    function _transferFromBefore(
        address from,
        address to,
        uint256 tokenID
    ) internal override(OpenERC721, OpenMarketable, OpenERC721Enumerable) {
        super._transferFromBefore(from, to, tokenID);
    }
}
