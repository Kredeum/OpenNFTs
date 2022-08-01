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

import "OpenNFTs/contracts/OpenERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";

abstract contract OpenERC2981 is IERC2981, OpenERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 fraction;
    }

    RoyaltyInfo internal _royaltyInfo;
    mapping(uint256 => RoyaltyInfo) internal _tokenRoyaltyInfo;

    uint96 internal constant _MAX_FEE = 10000;

    function royaltyInfo(uint256 tokenID, uint256 salePrice)
        public
        view
        override(IERC2981)
        returns (address receiver, uint256 royaltyAmount)
    {
        /// otherwise may overflow
        require(salePrice < 2**128, "Too expensive");

        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenID];

        if (royalty.receiver == address(0)) {
            royalty = _royaltyInfo;
        }

        royaltyAmount = (salePrice * royalty.fraction) / _MAX_FEE;

        return (royalty.receiver, royaltyAmount);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenERC165) returns (bool) {
        return interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }
}
