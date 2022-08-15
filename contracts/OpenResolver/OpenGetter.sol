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
    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenChecker) returns (bool) {
        return interfaceId == type(IOpenGetter).interfaceId || super.supportsInterface(interfaceId);
    }

    function getCollectionInfos(address collection)
        public
        view
        override(IOpenGetter)
        returns (CollectionInfos memory collectionInfos)
    {
        return _getCollectionInfos(collection, msg.sender);
    }

    function getCollectionsInfos(address[] memory collections, address account)
        public
        view
        override(IOpenGetter)
        returns (CollectionInfos[] memory collectionsInfos)
    {
        collectionsInfos = new CollectionInfos[](collections.length);
        for (uint256 i = 0; i < collections.length; i++) {
            collectionsInfos[i] = _getCollectionInfos(collections[i], account);
        }
    }

    function _getCollectionInfos(address collection, address account)
        private
        view
        returns (CollectionInfos memory collectionInfos)
    {
        require(collection.code.length != 0, "Not smartcontract");

        bool[] memory supported = checkErcInterfaces(collection);
        collectionInfos.supported = supported;

        // ERC165 must be supported
        require(!supported[0] && supported[1], "Not ERC165");

        // ERC721 or ERC1155 must be supported
        require(supported[2] || supported[6], "Not NFT smartcontract");

        collectionInfos.collection = collection;

        // IF ERC173 supported
        if (supported[9]) {
            collectionInfos.owner = IERC173(collection).owner();
        }

        // IF ERC721 supported
        if (supported[2]) {
            // IF ERC721Metadata supported
            if (supported[3]) {
                collectionInfos.name = IERC721Metadata(collection).name();
                collectionInfos.symbol = IERC721Metadata(collection).symbol();
            }

            // IF ERC721Enumerable supported
            if (supported[4]) {
                collectionInfos.totalSupply = IERC721Enumerable(collection).totalSupply();
            }

            if (account != address(0)) {
                collectionInfos.balanceOf = IERC721(collection).balanceOf(account);
            }
        }
    }
}
