// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenGetter is IERC721Infos {
    function getCollectionInfos(address collection) external view returns (CollectionInfos memory collectionInfos);

    function getNftInfos(address collection, uint256 tokenID) external view returns (NftInfos memory nftInfos);

    function getNftsInfos(
        address collection,
        address account,
        uint256 limit,
        uint256 offset
    )
        external
        view
        returns (
            NftInfos[] memory nftsInfos,
            uint256 count,
            uint256 total
        );

    function getNftsInfos(address collection, uint256[] memory tokenIDs)
        external
        view
        returns (NftInfos[] memory nftsInfos);
}
