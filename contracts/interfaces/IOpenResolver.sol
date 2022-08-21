// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenResolver is IERC721Infos {
    function getCollectionsInfos(
        address[] memory collections,
        address account,
        bytes4[] memory interfaceIds
    ) external view returns (CollectionInfos[] memory collectionsInfos);
}
