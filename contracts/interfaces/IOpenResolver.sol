// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721Infos.sol";

interface IOpenResolver is IERC721Infos {
    function openResolver(address account) external view returns (CollectionInfos[] memory collectionInfos);
}
