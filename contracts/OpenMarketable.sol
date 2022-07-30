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
//        ——————————————
//        |            |
//   OpenERC721    OpenERC173
//      (NFT)      (Ownable)
//        |            |
//   OpenERC2981       |
//  (RoyaltyInfo)      |
//        |            |
//        ——————————————
//        |
//  OpenMarketable
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC2981.sol";
import "OpenNFTs/contracts/OpenERC173.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenMarketable is IOpenMarketable, OpenERC2981, OpenERC173 {
    mapping(uint256 => uint256) public tokenPrice;
    uint256 public defaultPrice;

    modifier notTooExpensive(uint256 price) {
        /// otherwise may overflow
        require(price < 2**128, "Too expensive");
        _;
    }

    modifier lessThanMaxFee(uint256 fee) {
        require(fee <= _MAX_FEE, "Royalty fee exceed price");
        _;
    }

    // modifier beforeMinting() {
    //     require(totalSupply() == 0, "Some tokens already minted");
    //     _;
    // }

    /// @notice SET default royalty configuration
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10000
    function setDefaultRoyalty(address receiver, uint96 fee)
        external
        override(IOpenMarketable)
        onlyOwner
        lessThanMaxFee(fee)
    {
        _royaltyInfo = RoyaltyInfo(receiver, fee);
        emit SetDefaultRoyalty(receiver, fee);
    }

    /// @notice SET token royalty configuration
    /// @param tokenID : token ID
    /// @param receiver : address of the royalty receiver, or address(0) to reset
    /// @param fee : fee Numerator, less than 10000
    function setTokenRoyalty(
        uint256 tokenID,
        address receiver,
        uint96 fee
    ) external override(IOpenMarketable) onlyTokenOwnerOrApproved(tokenID) lessThanMaxFee(fee) {
        _setTokenRoyalty(tokenID, receiver, fee);
    }

    function setDefaultPrice(uint256 price) external override(IOpenMarketable) onlyOwner notTooExpensive(price) {
        defaultPrice = price;
    }

    function setTokenPrice(uint256 tokenID) external override(IOpenMarketable) {
        setTokenPrice(tokenID, defaultPrice);
    }

    function setTokenPrice(uint256 tokenID, uint256 price)
        public
        override(IOpenMarketable)
        onlyTokenOwnerOrApproved(tokenID)
        notTooExpensive(price)
    {
        _setTokenPrice(tokenID, price);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(OpenERC2981, OpenERC173)
        returns (bool)
    {
        return interfaceId == type(IOpenMarketable).interfaceId || super.supportsInterface(interfaceId);
    }

    function _setTokenRoyalty(
        uint256 tokenID,
        address receiver,
        uint96 fee
    ) internal {
        _tokenRoyaltyInfo[tokenID] = RoyaltyInfo(receiver, fee);
        emit SetTokenRoyalty(tokenID, receiver, fee);
    }

    function _setTokenPrice(uint256 tokenID, uint256 price) internal {
        tokenPrice[tokenID] = price;
    }

    function _mintMarketable(
        uint256 tokenID,
        address receiver,
        uint96 fee,
        uint256 price
    ) internal {
        _setTokenRoyalty(tokenID, receiver, fee);
        _setTokenPrice(tokenID, price);
    }

    function _burnMarketable(uint256 tokenID) internal {
        delete _tokenRoyaltyInfo[tokenID];
        delete tokenPrice[tokenID];
    }
}