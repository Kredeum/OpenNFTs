// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenGetter is IERC721Infos {
    function collectionInfosGet(address collection, address account)
        external
        view
        returns (CollectionInfos memory collectionInfo);

    function collectionsInfosGet(address[] memory collections, address account)
        external
        view
        returns (CollectionInfos[] memory collectionsInfo);
}
