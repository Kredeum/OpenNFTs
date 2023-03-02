// SPDX-License-Identifier: MIT
//
//    OpenERC165
//        |

//        |
//   OpenResolver
//        |
//  OpenResolverEx —— IOpenResolverEx
//
pragma solidity ^0.8.17;

import "OpenNFTs/contracts/OpenResolver/OpenResolver.sol";
import "OpenNFTs/contracts/examples/IOpenResolverEx.sol";

contract OpenResolverEx is IOpenResolverEx, OpenResolver {
    bytes4[] private _interfaceIds = new bytes4[](5);

    function initialize(address owner_, address registerer_) external override(IOpenResolverEx) {
        OpenERC173._initialize(owner_);
        _setRegisterer(registerer_);

        _interfaceIds[0] = type(IOpenChecker).interfaceId;
        _interfaceIds[1] = type(IOpenGetter).interfaceId;
        _interfaceIds[2] = type(IOpenRegistry).interfaceId;
        _interfaceIds[3] = type(IOpenResolver).interfaceId;
        _interfaceIds[4] = type(IOpenResolverEx).interfaceId;
    }

    function getResolverExCollectionInfos(address collection, address account)
        external
        view
        override(IOpenResolverEx)
        returns (CollectionInfos memory collectionInfos)
    {
        collectionInfos = _getCollectionInfos(collection, account, _interfaceIds);
    }

    function getResolverExCollectionsInfos(address account)
        external
        view
        override(IOpenResolverEx)
        returns (CollectionInfos[] memory collectionsInfos)
    {
        collectionsInfos = _getCollectionsInfos(account, _interfaceIds);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(OpenResolver)
        returns (bool)
    {
        return
            interfaceId == type(IOpenResolverEx).interfaceId || super.supportsInterface(interfaceId);
    }
}
