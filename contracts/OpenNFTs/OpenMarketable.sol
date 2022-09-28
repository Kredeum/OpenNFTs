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

    bool public minimal;

    ReceiverInfos internal _treasury;

    receive() external payable override (IOpenMarketable) {}

    /// @notice withdraw eth
    function withdraw() external override (IOpenMarketable) onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice SET default mint price
    /// @param price : default price in wei
    function setMintPrice(uint256 price) public override (IOpenMarketable) onlyOwner {
        _setMintPrice(price);
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
        _setTokenPrice(tokenID, price, address(this), Approve.All);
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

    function getMintPrice() public view override (IOpenMarketable) returns (uint256) {
        return _mintPrice;
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
    /// @return receiver : default royalty receiver infos
    function getDefaultRoyalty()
        public
        view
        override (IOpenMarketable)
        returns (ReceiverInfos memory receiver)
    {
        receiver = _defaultRoyalty;
    }

    /// @notice GET token royalty info
    /// @param tokenID : token ID
    /// @return receiver :  token royalty receiver infos
    function getTokenRoyalty(uint256 tokenID)
        public
        view
        override (IOpenMarketable)
        returns (ReceiverInfos memory receiver)
    {
        receiver = _tokenRoyalty[tokenID];
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

    function _initialize(
        uint256 mintPrice_,
        address receiver_,
        uint96 fee_,
        address treasury_,
        uint96 treasuryFee_,
        bool minimal_
    ) internal {
        _mintPrice = mintPrice_;
        _defaultRoyalty = ReceiverInfos(receiver_, fee_, 0);
        _treasury = ReceiverInfos(treasury_, treasuryFee_, 0);
        minimal = minimal_;
    }

    function _mint(address to, string memory tokenURI, uint256 tokenID)
        internal
        virtual
        override (OpenERC721)
    {
        _setTokenRoyalty(tokenID, _defaultRoyalty.account, _defaultRoyalty.fee);

        if (to != owner()) _pay(tokenID, _mintPrice, to, owner());

        super._mint(to, tokenURI, tokenID);
    }

    function _burn(uint256 tokenID) internal virtual override (OpenERC721) {
        delete _tokenRoyalty[tokenID];
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
        _defaultRoyalty = ReceiverInfos(receiver, fee, 0);

        emit SetDefaultRoyalty(receiver, fee);
    }

    function _setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee)
        internal
        lessThanMaxFee(fee)
    {
        uint256 minimum = minimal ? _calculateAmount(_mintPrice, fee) : 0;

        _tokenRoyalty[tokenID] = ReceiverInfos(receiver, fee, minimum);

        emit SetTokenRoyalty(tokenID, receiver, fee);
    }

    /// @notice SET token price
    /// @param tokenID : token ID
    /// @param price : token price in wei
    function _setTokenPrice(uint256 tokenID, uint256 price, address approved, Approve approveType)
        internal
        onlyTokenOwnerOrApproved(tokenID)
        notTooExpensive(price)
    {
        _tokenPrice[tokenID] = price;

        emit SetTokenPrice(tokenID, price);

        if (approveType == Approve.All) {
            setApprovalForAll(approved, true);
        } else if (approveType == Approve.One) {
            approve(approved, tokenID);
        }
    }

    function _setMintPrice(uint256 price) internal notTooExpensive(price) {
        _mintPrice = price;

        emit SetMintPrice(price);
    }

    function _pay(uint256 tokenID, uint256 price, address buyer, address seller)
        private
        reEntryGuard
    {
        require(msg.value >= price, "Not enough funds");
        require(buyer != address(0), "Invalid buyer");
        require(seller != address(0), "Invalid seller");

        address receiver;
        uint256 royalties;
        uint256 fee;
        uint256 paid;
        uint256 unspent = msg.value;

        (receiver, royalties) = royaltyInfo(tokenID, price);
        if (receiver == address(0)) royalties = 0;

        if (royalties > 0 || price > 0) {
            fee = _calculateAmount(price, _treasury.fee);
            require(msg.value >= royalties + fee, "Not enough funds");

            /// Transfer amount to be paid to seller
            if (price > royalties + fee) {
                paid = price - (royalties + fee);
                unspent = unspent - paid;
                payable(seller).transfer(paid);
            }

            /// Transfer royalties to receiver
            if (royalties > 0) {
                unspent = unspent - royalties;
                payable(receiver).transfer(royalties);
            }

            /// Transfer fee to protocol treasury
            if (fee > 0) {
                unspent = unspent - fee;
                payable(_treasury.account).transfer(fee);
            }
        }

        assert(paid + royalties + fee + unspent == msg.value);

        /// Transfer back unspent funds to sender
        if (unspent > 0) payable(buyer).transfer(unspent);

        emit Pay(tokenID, price, seller, paid, receiver, royalties, fee, buyer, unspent);
    }
}
