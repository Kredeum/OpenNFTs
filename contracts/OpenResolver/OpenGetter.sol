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
pragma solidity ^0.8.17;

import "OpenNFTs/contracts/OpenResolver/OpenChecker.sol";
import "OpenNFTs/contracts/interfaces/IOpenGetter.sol";
import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Metadata.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IERC1155.sol";
import "OpenNFTs/contracts/interfaces/IERC1155MetadataURI.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC173.sol";

abstract contract OpenGetter is IOpenGetter, OpenChecker {
    uint8 private constant _INVALID = 0;
    uint8 private constant _ERC165 = 1;
    uint8 private constant _ERC721 = 2;
    uint8 private constant _ERC721_ENUMERABLE = 2;
    uint8 private constant _ERC1155 = 6;
    bytes4 private constant _ERC721_ID = 0x80ac58cd;
    bytes4 private constant _ERC1155_ID = 0xd9b67a26;
    bytes4 private constant _ERC721_METADATA_ID = 0x5b5e139f;
    bytes4 private constant _ERC1155_METADATA_URI_ID = 0x0e89341c;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(OpenChecker)
        returns (bool)
    {
        return interfaceId == type(IOpenGetter).interfaceId || super.supportsInterface(interfaceId);
    }

    function getCollectionInfos(address collection, address account)
        public
        view
        override(IOpenGetter)
        returns (
            // override(IOpenGetter)
            CollectionInfos memory collectionInfos
        )
    {
        collectionInfos = _getCollectionInfos(collection, account, new bytes4[](0));
    }

    function getNftsInfos(address collection, uint256[] memory tokenIDs, address account)
        public
        view
        override(IOpenGetter)
        returns (NftInfos[] memory nftsInfos)
    {
        uint256 len = tokenIDs.length;
        nftsInfos = new NftInfos[](len);
        for (uint256 i; i < len; i++) {
            nftsInfos[i] = _getNftInfos(collection, tokenIDs[i], account);
        }
    }

    function getNftsInfos(address collection, address account, uint256 limit, uint256 offset)
        public
        view
        override(IOpenGetter)
        returns (NftInfos[] memory nftsInfos, uint256 count, uint256 total)
    {
        bool[] memory supported = checkErcInterfaces(collection);

        // IF ERC721 & ERC721Enumerable supported
        if (supported[_ERC721] && supported[_ERC721_ENUMERABLE]) {
            if (account == address(0)) {
                total = IERC721Enumerable(collection).totalSupply();

                require(offset <= total, "Invalid offset");
                count = (offset + limit <= total) ? limit : total - offset;

                nftsInfos = new NftInfos[](count);
                for (uint256 i; i < count; i++) {
                    nftsInfos[i] = _getNftInfos(
                        collection, IERC721Enumerable(collection).tokenByIndex(offset + i), account
                    );
                }
            } else {
                total = IERC721(collection).balanceOf(account);

                require(offset <= total, "Invalid offset");
                count = (offset + limit <= total) ? limit : total - offset;

                nftsInfos = new NftInfos[](count);
                for (uint256 i; i < count; i++) {
                    nftsInfos[i] = _getNftInfos(
                        collection,
                        IERC721Enumerable(collection).tokenOfOwnerByIndex(account, offset + i),
                        account
                    );
                }
            }
        }
    }

    function getNftInfos(address collection, uint256 tokenID, address account)
        public
        view
        override(IOpenGetter)
        returns (NftInfos memory nftInfos)
    {
        return _getNftInfos(collection, tokenID, account);
    }

    function _getNftInfos(address collection, uint256 tokenID, address account)
        internal
        view
        onlyContract(collection)
        returns (NftInfos memory nftInfos)
    {
        nftInfos.tokenID = tokenID;

        if (IERC165(collection).supportsInterface(_ERC721_ID)) {
            try IERC721(collection).ownerOf(tokenID) returns (address owner) {
                nftInfos.owner = owner;
            } catch {}

            // tokenID exists <=> owner != 0
            if (nftInfos.owner != address(0)) {
                nftInfos.approved = IERC721(collection).getApproved(tokenID);
                if (IERC165(collection).supportsInterface(_ERC721_METADATA_ID)) {
                    nftInfos.tokenURI = IERC721Metadata(collection).tokenURI(tokenID);
                }
            }
        } else if (IERC165(collection).supportsInterface(_ERC1155_ID)) {
            if (account != address(0)) {
                nftInfos.balanceOf = IERC1155(collection).balanceOf(account, tokenID);
            }
            if (IERC165(collection).supportsInterface(_ERC1155_METADATA_URI_ID)) {
                nftInfos.tokenURI = IERC1155MetadataURI(collection).uri(tokenID);
            }
        }
    }

    function _getCollectionInfos(address collection, address account, bytes4[] memory interfaceIds)
        internal
        view
        onlyContract(collection)
        returns (CollectionInfos memory collectionInfos)
    {
        bool[] memory supported = checkSupportedInterfaces(collection, true, interfaceIds);
        collectionInfos.supported = supported;

        // ERC165 must be supported
        require(!supported[_INVALID] && supported[_ERC165], "Not ERC165");

        // ERC721 or ERC1155 must be supported
        require(supported[_ERC721] || supported[_ERC1155], "Not NFT smartcontract");

        collectionInfos.collection = collection;

        // try ERC173 owner
        try IERC173(collection).owner() returns (address owner) {
            collectionInfos.owner = owner;
        } catch {}

        // try ERC721Metadata name
        try IERC721Metadata(collection).name() returns (string memory name) {
            collectionInfos.name = name;
        } catch {}

        // try ERC721Metadata symbol
        try IERC721Metadata(collection).symbol() returns (string memory symbol) {
            collectionInfos.symbol = symbol;
        } catch {}

        // try ERC721Enumerable totalSupply
        try IERC721Enumerable(collection).totalSupply() returns (uint256 totalSupply) {
            collectionInfos.totalSupply = totalSupply;
        } catch {}

        if (account != address(0)) {
            try IERC721(collection).balanceOf(account) returns (uint256 balanceOf) {
                collectionInfos.balanceOf = balanceOf;
            } catch {}

            try IERC721(collection).isApprovedForAll(account, collection) returns (
                bool approvedForAll
            ) {
                collectionInfos.approvedForAll = approvedForAll;
            } catch {}
        }
    }
}
