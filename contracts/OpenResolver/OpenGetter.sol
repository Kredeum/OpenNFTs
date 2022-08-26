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
        collectionInfos = _getCollectionInfos(collection, msg.sender, new bytes4[](0));
    }

    function getNftsInfos(
        address collection,
        address account,
        uint256 limit,
        uint256 offset
    )
        public
        view
        returns (
            NftInfos[] memory nftsInfos,
            uint256 count,
            uint256 total
        )
    {
        bool[] memory supported = checkErcInterfaces(collection);

        // IF ERC721 & ERC721Enumerable supported
        if (supported[2] && supported[4]) {
            if (account == address(0)) {
                total = IERC721Enumerable(collection).totalSupply();

                require(offset <= total, "Invalid offset");
                count = (offset + limit <= total) ? limit : total - offset;

                nftsInfos = new NftInfos[](count);
                for (uint256 i; i < count; i++) {
                    nftsInfos[i] = getNftInfos(
                        collection,
                        IERC721Enumerable(collection).tokenByIndex(offset + i),
                        supported[3]
                    );
                }
            } else {
                total = IERC721(collection).balanceOf(account);

                require(offset <= total, "Invalid offset");
                count = (offset + limit <= total) ? limit : total - offset;

                nftsInfos = new NftInfos[](count);
                for (uint256 i; i < count; i++) {
                    nftsInfos[i] = getNftInfos(
                        collection,
                        IERC721Enumerable(collection).tokenOfOwnerByIndex(account, offset + i),
                        supported[3]
                    );
                }
            }
        }
    }

    function getNftInfos(
        address collection,
        uint256 tokenID,
        bool erc721Metadata
    ) public view returns (NftInfos memory nftInfos) {
        nftInfos.tokenID = tokenID;
        nftInfos.approved = IERC721(collection).getApproved(tokenID);
        nftInfos.owner = IERC721(collection).ownerOf(tokenID);

        // IF ERC721Metadata supported
        if (erc721Metadata) {
            nftInfos.tokenURI = IERC721Metadata(collection).tokenURI(tokenID);
        }
    }

    function _getCollectionInfos(
        address collection,
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (CollectionInfos memory collectionInfos) {
        require(collection.code.length != 0, "Not smartcontract");

        bool[] memory supported = checkSupportedInterfaces(collection, true, interfaceIds);
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
