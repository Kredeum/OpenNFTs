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
//  OpenChecker —— IOpenChecker
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC/OpenERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenChecker.sol";

abstract contract OpenChecker is IOpenChecker, OpenERC165 {
    /// ercInterfaceIds : ERC interfacesIds
    /// 0xffffffff :  O Invalid
    /// 0x01ffc9a7 :  1 ERC165
    /// 0x80ac58cd :  2 ERC721
    /// 0x5b5e139f :  3 ERC721Metadata
    /// 0x780e9d63 :  4 ERC721Enumerable
    /// 0x150b7a02 :  5 ERC721TokenReceiver
    /// 0xd9b67a26 :  6 ERC1155
    /// 0x0e89341c :  7 ERC1155MetadataURI
    /// 0x4e2312e0 :  8 ERC1155TokenReceiver
    /// 0x7f5828d0 :  9 ERC173
    /// 0x2a55205a : 10 ERC2981
    bytes4[] public ercInterfaceIds = [
        bytes4(0xffffffff),
        bytes4(0x01ffc9a7),
        bytes4(0x80ac58cd),
        bytes4(0x5b5e139f),
        bytes4(0x780e9d63),
        bytes4(0x150b7a02),
        bytes4(0xd9b67a26),
        bytes4(0x0e89341c),
        bytes4(0x4e2312e0),
        bytes4(0x7f5828d0),
        bytes4(0x2a55205a)
    ];

    function checkSupportedInterfaces(address account) public view returns (bool[] memory interfaceIdsChecker) {
        return checkSupportedInterfaces(account, ercInterfaceIds);
    }

    function checkSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        public
        view
        returns (bool[] memory interfaceIdsChecker)
    {
        interfaceIdsChecker = new bool[](interfaceIds.length);
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            interfaceIdsChecker[i] = IERC165(account).supportsInterface(interfaceIds[i]);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenERC165) returns (bool) {
        return interfaceId == type(IOpenChecker).interfaceId || super.supportsInterface(interfaceId);
    }
}
