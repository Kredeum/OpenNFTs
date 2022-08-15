// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenNFTs/contracts/interfaces/IERC721Infos.sol";

interface IOpenResolver is IERC721Infos {
    function openResolverFiltered(address account)
        external
        view
        returns (CollectionInfos[] memory collectionInfosFiltered);

    function openResolver(address account) external view returns (CollectionInfos[] memory collectionInfos);
}
