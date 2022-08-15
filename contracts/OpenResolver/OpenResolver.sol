// SPDX-License-Identifier: MIT
//
// Derived from OpenZeppelin Contracts (utils/introspection/ERC165Ckecker.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165Checker.sol
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
//   OpenERC165
//        |
//        ————————————————
//        |              |
//   OpenChecker     OpenERC173
//        |              |
//    OpenGetter    OpenRegistry
//        |              |
//        ————————————————
//        |
//  OpenResolver —— IOpenResolver
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenResolver/OpenRegistry.sol";
import "OpenNFTs/contracts/OpenResolver/OpenGetter.sol";
import "OpenNFTs/contracts/interfaces/IOpenResolver.sol";

abstract contract OpenResolver is IOpenResolver, OpenRegistry, OpenGetter {
    function openResolverFiltered(address account)
        external
        view
        override(IOpenResolver)
        returns (CollectionInfos[] memory collectionsInfosFiltered)
    {
        CollectionInfos[] memory collectionsInfos = openResolver(account);
        uint256 j;

        for (uint256 i = 0; i < collectionsInfos.length; i++) {
            if (collectionsInfos[i].balanceOf > 0) collectionsInfosFiltered[j++] = collectionsInfos[i];
        }
    }

    function openResolver(address account)
        public
        view
        override(IOpenResolver)
        returns (CollectionInfos[] memory collectionsInfos)
    {
        return getCollectionsInfos(_addresses, account);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(OpenRegistry, OpenGetter)
        returns (bool)
    {
        return interfaceId == type(IOpenResolver).interfaceId || super.supportsInterface(interfaceId);
    }
}
