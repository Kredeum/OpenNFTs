// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenGetter is IERC721Infos {
    function getCollectionInfos(address collection) external view returns (CollectionInfos memory collectionInfos);
}
