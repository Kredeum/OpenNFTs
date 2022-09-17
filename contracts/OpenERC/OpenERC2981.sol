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
    struct RoyaltyInfo {
        address receiver;
        uint96 fee;
    }

    uint256 internal _defaultPrice;
    RoyaltyInfo internal _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) internal _tokenRoyaltyInfo;

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
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenID];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        royaltyAmount = (price * royalty.fee) / _MAX_FEE;

        return (royalty.receiver, royaltyAmount);
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
}
