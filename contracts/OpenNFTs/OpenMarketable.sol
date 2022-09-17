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
//  OpenMarketable —— IOpenMarketable - OpenGuard
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC173.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC2981.sol";
import "OpenNFTs/contracts/OpenNFTs/OpenGuard.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenMarketable is
    IOpenMarketable,
    OpenERC721,
    OpenERC173,
    OpenERC2981,
    OpenGuard
{
    mapping(uint256 => uint256) internal _tokenPrice;

    address payable internal _treasury;
    uint96 internal _treasuryFee;

    receive() external payable override (IOpenMarketable) {}

    /// @notice withdraw eth
    function withdraw() external override (IOpenMarketable) onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice SET default mint price
    /// @param price : default price in wei
    function setDefaultPrice(uint256 price) public override (IOpenMarketable) onlyOwner {
        _setDefaultPrice(price);
    }

    /// @notice SET default royalty info
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10000
    function setDefaultRoyalty(address receiver, uint96 fee)
        public
        override (IOpenMarketable)
        onlyOwner
    {
        _setDefaultRoyalty(receiver, fee);
    }

    /// @notice SET token price
    /// @param tokenID : token ID
    /// @param price : token price in wei
    function setTokenPrice(uint256 tokenID, uint256 price)
        public
        override (IOpenMarketable)
        onlyTokenOwnerOrApproved(tokenID)
    {
        setTokenPrice(tokenID, price, address(0), Approve.None);
    }

    /// @notice SET token price
    /// @param tokenID : token ID
    /// @param price : token price in wei
    function setTokenPrice(uint256 tokenID, uint256 price, address approved, Approve approveType)
        public
        override (IOpenMarketable)
        onlyTokenOwnerOrApproved(tokenID)
    {
        _setTokenPrice(tokenID, price);

        if (approveType == Approve.All) {
            setApprovalForAll(approved, true);
        } else if (approveType == Approve.One) {
            approve(approved, tokenID);
        }
    }

    /// @notice SET token royalty info
    /// @param tokenID : token ID
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10_000
    function setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee)
        public
        override (IOpenMarketable)
        existsToken(tokenID)
        onlyOwner
        onlyTokenOwnerOrApproved(tokenID)
    {
        _setTokenRoyalty(tokenID, receiver, fee);
    }

    /// @notice SET token royalty receiver
    /// @param tokenID : token ID
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    function setTokenRoyaltyReceiver(uint256 tokenID, address receiver)
        public
        override (IOpenMarketable)
        existsToken(tokenID)
        onlyOwner
    {
        _tokenRoyaltyInfo[tokenID].receiver = receiver;
    }

    function getDefaultPrice() public view override (IOpenMarketable) returns (uint256) {
        return _defaultPrice;
    }

    function getTokenPrice(uint256 tokenID)
        public
        view
        override (IOpenMarketable)
        returns (uint256)
    {
        return _tokenPrice[tokenID];
    }

    /// @notice GET default royalty info
    /// @return receiver : address of the royalty receiver, or address(0) to reset
    /// @return fee : fee Numerator, less than 10_000
    function getDefaultRoyalty()
        public
        view
        override (IOpenMarketable)
        returns (address receiver, uint96 fee)
    {
        receiver = _defaultRoyaltyInfo.receiver;
        fee = _defaultRoyaltyInfo.fee;
    }

    /// @notice GET token royalty info
    /// @param tokenID : token ID
    /// @return receiver : address of the royalty receiver, or address(0) to reset
    /// @return fee : fee Numerator, less than 10_000
    function getTokenRoyalty(uint256 tokenID)
        public
        view
        override (IOpenMarketable)
        returns (address receiver, uint96 fee)
    {
        receiver = _tokenRoyaltyInfo[tokenID].receiver;
        fee = _tokenRoyaltyInfo[tokenID].fee;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (OpenERC721, OpenERC173, OpenERC2981)
        returns (bool)
    {
        return interfaceId == type(IOpenMarketable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function _initialize(address payable treasury_, uint96 treasuryFee_) internal {
        _treasury = treasury_;
        _treasuryFee = treasuryFee_;
    }

    function _mint(address to, string memory tokenURI, uint256 tokenID)
        internal
        virtual
        override (OpenERC721)
    {
        _setTokenRoyalty(tokenID, _defaultRoyaltyInfo.receiver, _defaultRoyaltyInfo.fee);

        _pay(tokenID, _defaultPrice, to, owner());

        super._mint(to, tokenURI, tokenID);
    }

    function _burn(uint256 tokenID) internal virtual override (OpenERC721) {
        delete _tokenRoyaltyInfo[tokenID];
        delete _tokenPrice[tokenID];

        super._burn(tokenID);
    }

    function _transferFromBefore(address from, address to, uint256 tokenID)
        internal
        virtual
        override (OpenERC721)
    {
        /// Transfer: pay token price (including royalties) to previous token owner (and royalty receiver)
        _pay(tokenID, _tokenPrice[tokenID], to, ownerOf(tokenID));

        delete _tokenPrice[tokenID];

        super._transferFromBefore(from, to, tokenID);
    }

    function _setDefaultRoyalty(address receiver, uint96 fee) internal lessThanMaxFee(fee) {
        _defaultRoyaltyInfo = RoyaltyInfo(receiver, fee);

        emit SetDefaultRoyalty(receiver, fee);
    }

    function _setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee)
        internal
        lessThanMaxFee(fee)
    {
        _tokenRoyaltyInfo[tokenID] = RoyaltyInfo(receiver, fee);

        emit SetTokenRoyalty(tokenID, receiver, fee);
    }

    function _setTokenPrice(uint256 tokenID, uint256 price) internal notTooExpensive(price) {
        _tokenPrice[tokenID] = price;

        emit SetTokenPrice(tokenID, price);
    }

    function _setDefaultPrice(uint256 price) internal notTooExpensive(price) {
        _defaultPrice = price;

        emit SetDefaultPrice(price);
    }

    function _pay(uint256 tokenID, uint256 price, address buyer, address seller)
        private
        reEntryGuard
    {
        require(msg.value >= price, "Not enough funds");
        if (msg.value == 0) {
            return;
        }

        require(buyer != address(0), "Invalid buyer");
        require(seller != address(0), "Invalid seller");
        address receiver;
        uint256 royalties;
        uint256 fee;
        uint256 paid;
        uint256 unspent = msg.value;

        if (price > 0 && buyer != seller) {
            fee = _calculateAmount(price, _treasuryFee);

            (receiver, royalties) = royaltyInfo(tokenID, price);
            if (receiver == address(0)) {
                royalties = 0;
            }

            require(royalties + fee <= price, "Invalid royalties");

            /// Transfer amount to be paid to seller, the previous owner
            paid = price - (royalties + fee);
            if (paid > 0) {
                unspent = unspent - paid;
                payable(seller).transfer(paid);
            }

            /// Transfer royalties to receiver
            if (royalties > 0) {
                unspent = unspent - royalties;
                payable(receiver).transfer(royalties);
            }

            /// Transfer fee to treasury
            if (fee > 0) {
                unspent = unspent - fee;
                payable(_treasury).transfer(fee);
            }
        }

        assert(paid + royalties + fee + unspent == msg.value);

        /// Transfer back unspent funds to buyer
        if (unspent > 0) {
            payable(buyer).transfer(unspent);
        }

        emit Pay(tokenID, price, seller, paid, receiver, royalties, fee, buyer, unspent);
    }
}
