// SPDX-License-Identifier: MIT
//
// EIP-5192: Minimal Soulbound NFTs Standard
// https://eips.ethereum.org/EIPS/eip-5192
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
//  OpenERC721
//       |
//  OpenERC5192 —— IERC5192
//
pragma solidity ^0.8.17;

import "OpenNFTs/contracts/OpenERC/OpenERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC5192.sol";

abstract contract OpenERC5192 is IERC5192, OpenERC721 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (OpenERC721)
        returns (bool)
    {
        return interfaceId == 0xb45a3c0e || super.supportsInterface(interfaceId);
    }

    function locked(uint256) public pure override (IERC5192) returns (bool) {
        return true;
    }

    function _mint(address to, string memory tokenURI, uint256 tokenID)
        internal
        virtual
        override (OpenERC721)
    {
        super._mint(to, tokenURI, tokenID);

        emit Locked(tokenID);
    }
}
