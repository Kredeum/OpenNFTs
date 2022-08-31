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
//        |
//        ————————————————————————————
//        |            |             |
//   OpenERC721    OpenERC173   OpenERC2981
//      (NFT)      (Ownable)   (RoyaltyInfo)
//        |            |             |
//        ————————————————————————————
//        |
//  OpenMarketable —— IOpenMarketable
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC173.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC2981.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenMarketable is IOpenMarketable, OpenERC721, OpenERC173, OpenERC2981 {
    mapping(uint256 => uint256) public tokenPrice;
    uint256 public defaultPrice;

    receive() external payable override (IOpenMarketable) {}

    function setTokenPrice(uint256 tokenID) external override (IOpenMarketable) {
        setTokenPrice(tokenID, defaultPrice);
    }

    /// @notice SET default royalty configuration
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10000
    function setDefaultRoyalty(address receiver, uint96 fee) public override (IOpenMarketable) onlyOwner {
        _setDefaultRoyalty(receiver, fee);
    }

    function setDefaultPrice(uint256 price) public override (IOpenMarketable) onlyOwner {
        _setDefaultPrice(price);
    }

    /// @notice SET token royalty configuration
    /// @param tokenID : token ID
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10000
    function setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee)
        public
        override (IOpenMarketable)
        onlyTokenOwnerOrApproved(tokenID)
    {
        _setTokenRoyalty(tokenID, receiver, fee);
    }

    function setTokenPrice(uint256 tokenID, uint256 price)
        public
        override (IOpenMarketable)
        onlyTokenOwnerOrApproved(tokenID)
    {
        _setTokenPrice(tokenID, price);
    }

    function getDefaultRoyaltyInfo()
        public
        view
        override (IOpenMarketable)
        returns (address receiver, uint96 fraction)
    {
        receiver = _defaultRoyaltyInfo.receiver;
        fraction = _defaultRoyaltyInfo.fraction;
    }

    function getTokenRoyaltyInfo(uint256 tokenID)
        public
        view
        override (IOpenMarketable)
        returns (address receiver, uint96 fraction)
    {
        receiver = _tokenRoyaltyInfo[tokenID].receiver;
        fraction = _tokenRoyaltyInfo[tokenID].fraction;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (OpenERC721, OpenERC173, OpenERC2981)
        returns (bool)
    {
        return interfaceId == type(IOpenMarketable).interfaceId || super.supportsInterface(interfaceId);
    }

    function _mint(address to, string memory tokenURI, uint256 tokenID) internal virtual override (OpenERC721) {
        super._mint(to, tokenURI, tokenID);

        _pay(tokenID, defaultPrice, to, owner());
    }

    function _burn(uint256 tokenID) internal virtual override (OpenERC721) {
        delete _tokenRoyaltyInfo[tokenID];
        delete tokenPrice[tokenID];

        super._burn(tokenID);
    }

    function _transferFromBefore(address from, address to, uint256 tokenID) internal virtual override (OpenERC721) {
        /// Transfer: pay token price (including royalties) to previous token owner (and royalty receiver)
        _pay(tokenID, tokenPrice[tokenID], to, ownerOf(tokenID));
        delete tokenPrice[tokenID];

        super._transferFromBefore(from, to, tokenID);
    }

    function _setDefaultRoyalty(address receiver, uint96 fee) internal lessThanMaxFee(fee) {
        _defaultRoyaltyInfo = RoyaltyInfo(receiver, fee);

        emit SetDefaultRoyalty(receiver, fee);
    }

    function _setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee) internal lessThanMaxFee(fee) {
        _tokenRoyaltyInfo[tokenID] = RoyaltyInfo(receiver, fee);

        emit SetTokenRoyalty(tokenID, receiver, fee);
    }

    function _setTokenPrice(uint256 tokenID, uint256 price) internal notTooExpensive(price) {
        tokenPrice[tokenID] = price;

        emit SetTokenPrice(tokenID, price);
    }

    function _setDefaultPrice(uint256 price) internal notTooExpensive(price) {
        defaultPrice = price;

        emit SetDefaultPrice(price);
    }

    function _pay(uint256 tokenID, uint256 price, address payer, address payee) private {
        uint256 unspent = msg.value;

        if (price > 0) {
            /// Require enough value sent
            require(unspent >= price, "Not enough funds");

            (address receiver, uint256 royalties) = royaltyInfo(tokenID, price);

            require(royalties <= price, "Invalid royalties");
            uint256 paid = price - royalties;

            /// Transfer amount to previous payee
            if (paid > 0) {
                payable(payee).transfer(paid);
                unspent = unspent - paid;
            }

            /// Transfer royalties to receiver
            if (royalties > 0) {
                payable(receiver).transfer(royalties);
                unspent = unspent - royalties;
            }

            emit Pay(tokenID, price, payer, payee);
        }

        /// Transfer back unspent funds to payer
        if (unspent > 0) {
            payable(payer).transfer(unspent);
        }
    }
}
