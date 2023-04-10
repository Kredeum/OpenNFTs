// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "OpenNFTs/contracts/interfaces/IERCNftInfos.sol";

interface IOpenResolverEx is IERCNftInfos {
  function initialize(address owner, address registerer) external;

  function getResolverExCollectionInfos(address collection, address account)
    external
    view
    returns (CollectionInfos memory collectionInfos);

  function getResolverExCollectionsInfos(address account)
    external
    view
    returns (CollectionInfos[] memory collectionsInfos);
}
