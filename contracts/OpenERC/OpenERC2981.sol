// SPDX-License-Identifier: MIT
//
// EIP-2981: NFT Royalty Standard
// https://eips.ethereum.org/EIPS/eip-2981
//
// Derived from OpenZeppelin Contracts (token/common/ERC2981.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/common/ERC2981.sol
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
//  OpenERC165
//       |
//  OpenERC2981 —— IERC2981
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";

abstract contract OpenERC2981 is IERC2981, OpenERC165 {
    struct Receiver {
        address account;
        uint96 fee;
    }

    uint256 internal _defaultPrice;
    Receiver internal _defaultRoyalty;
    mapping(uint256 => Receiver) internal _tokenRoyalty;

    uint96 private constant _MAX_FEE = 10_000;

    modifier notTooExpensive(uint256 price) {
        /// otherwise may overflow
        require(price < 2 ** 128, "Too expensive");
        _;
    }

    modifier lessThanMaxFee(uint256 fee) {
        require(fee <= _MAX_FEE, "Royalty fee exceed price");
        _;
    }

    function royaltyInfo(uint256 tokenID, uint256 price)
        public
        view
        override (IERC2981)
        notTooExpensive(price)
        returns (address receiver, uint256 royaltyAmount)
    {
        Receiver memory royalty = _tokenRoyalty[tokenID];

        if (royalty.account == address(0)) {
            royalty = _defaultRoyalty;
        }

        royaltyAmount = _calculateAmount(price, royalty.fee);

        return (royalty.account, royaltyAmount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (OpenERC165)
        returns (bool)
    {
        return interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }

    function _calculateAmount(uint256 price, uint96 fee) internal pure returns (uint256) {
        return (price * fee) / _MAX_FEE;
    }
}
