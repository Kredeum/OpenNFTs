// SPDX-License-Identifier: MIT
//     ___           ___         ___           ___                    ___           ___                     ___
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
//  OpenERC165 (supports)
//      |
//      ——————————————————————————————————————————————————————————————————————————————————————
//      |                                                        |             |             |
//  OpenERC721 (NFT)                                         OpenERC173  OpenCheckable  OpenCloneable
//      |                                                    (ownable)         |             |
//      ————————————————————————————————————————————             |             |             |
//      |                        |                 |             |             |             |
// OpenERC721Metadata  OpenERC721Enumerable  OpenERC2981         |             |             |
//      |                        |           (RoyaltyInfo)       |             |             |
//      |                        |                 |             |             |             |
//      |                        |                 ———————————————             |             |
//      |                        |                 |             |             |             |
//      |                        |           OpenMarketable OpenPauseable      |             |
//      |                        |                 |             |             |             |
//      ——————————————————————————————————————————————————————————————————————————————————————
//      |
//   OpenNFTs —— IOpenNFTs
//
pragma solidity 0.8.9;

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

    /// @notice withdraw token or eth
    function withdraw(address token) external override(IOpenNFTs) onlyOwner {
        if (token.code.length == 0) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            require(IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this))), "Withdraw failed");
        }
    }

    function buy(uint256 tokenID) external payable override(IOpenNFTs) {
        /// Get token price
        uint256 price = tokenPrice[tokenID];

        /// Require price defined
        require(price > 0, "Not to sell");

        /// Require enough value sent
        require(msg.value >= price, "Not enough funds");

        /// Get previous token owner
        address from = ownerOf(tokenID);
        assert(from != address(0));
        require(from != msg.sender, "Already token owner!");

        /// Reset token price (to be eventualy defined by new owner)
        delete tokenPrice[tokenID];

        /// Transfer token
        this.safeTransferFrom(from, msg.sender, tokenID);

        (address receiver, uint256 royalties) = royaltyInfo(tokenID, price);

        assert(price >= royalties);
        uint256 paid = price - royalties;
        uint256 unspent = msg.value - price;
        assert(paid + royalties + unspent == msg.value);

        /// Transfer amount to previous owner
        payable(from).transfer(paid);

        /// Transfer royalties to receiver
        if (royalties > 0) payable(receiver).transfer(royalties);

        /// Transfer back unspent funds to sender
        if (unspent > 0) payable(msg.sender).transfer(unspent);
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
    /// @param jsonURI json URI of NFT metadata
    function _mint(address minter, string memory jsonURI) internal returns (uint256 tokenID) {
        tokenID = tokenIdNext++;

        // _mintMarketable(tokenID);
        _mintMetadata(tokenID, jsonURI);
        _mintEnumerable(minter, tokenID);
        _mintNft(minter, tokenID);
    }

    function _burn(uint256 tokenID) internal {
        _burnMarketable(tokenID);
        _burnMetadata(tokenID);
        _burnEnumerable(tokenID);
        _burnNft(tokenID);
    }

    function _transferFromBefore(
        address from,
        address to,
        uint256 tokenID
    ) internal override(OpenERC721, OpenERC721Enumerable) {
        OpenERC721Enumerable._transferFromBefore(from, to, tokenID);
    }
}
