// SPDX-License-Identifier: MIT
//
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
//   OpenChecker
//        |
//  OpenGetter —— IOpenGetter
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenResolver/OpenChecker.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Metadata.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IERC173.sol";

abstract contract OpenGetter is IOpenGetter, OpenChecker {
    bytes4[] internal _ids = [
        bytes4(0x01ffc9a7), // ERC165
        bytes4(0xffffffff), // Invalid
        bytes4(0x7f5828d0), // ERC173
        bytes4(0xd9b67a26), // ERC1155
        bytes4(0x80ac58cd), // ERC721
        bytes4(0x5b5e139f), // ERC721Metadata
        bytes4(0x780e9d63) // ERC721Enumerable
    ];

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenChecker) returns (bool) {
        return interfaceId == type(IOpenGetter).interfaceId || super.supportsInterface(interfaceId);
    }

    function getCollectionsInfos(address[] memory collections, address account)
        public
        view
        override(IOpenGetter)
        returns (CollectionInfos[] memory collectionsInfo)
    {
        collectionsInfo = new CollectionInfos[](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            collectionsInfo[i] = _getCollectionInfos(collections[i], account);
        }
    }

    function _getCollectionInfos(address collection, address account)
        internal
        view
        returns (CollectionInfos memory collectionInfo)
    {
        require(collection.code.length != 0, "Not smartcontract");

        bool[] memory supported = new bool[](4);
        supported = checkSupportedInterfaces(collection, _ids);

        // ERC165 must be supported
        require(supported[0] && !supported[1], "Not ERC165");

        // ERC721 or ERC1155 must be supported
        require(supported[3] || supported[4], "Not NFT smartcontract");

        if (account == address(0)) account = msg.sender;
        collectionInfo.collection = collection;

        // IF ERC721 supported
        if (supported[4]) {
            collectionInfo.balanceOf = IERC721(collection).balanceOf(account);

            // IF ERC721Metadata supported
            if (supported[5]) {
                collectionInfo.name = IERC721Metadata(collection).name();
                collectionInfo.symbol = IERC721Metadata(collection).symbol();
            }

            // IF ERC721Enumerable supported
            if (supported[6]) {
                collectionInfo.totalSupply = IERC721Enumerable(collection).totalSupply();
            }
        }

        // IF ERC173 supported
        if (supported[2]) {
            collectionInfo.owner = IERC173(collection).owner();
        }
    }
}
