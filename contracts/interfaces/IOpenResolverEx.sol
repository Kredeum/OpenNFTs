// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenResolverEx is IERC721Infos {
    function initialize(address owner) external;

    function getResolverExCollectionInfos(address collection, address account)
        external
        view
        returns (CollectionInfos memory collectionInfos);

    function getResolverExCollectionsInfos(address account)
        external
        view
        returns (CollectionInfos[] memory collectionsInfos);
}
