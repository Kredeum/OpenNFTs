// SPDX-License-Identifier: MIT
//
//    OpenERC165
//        |

//        |
//   OpenResolver
//        |
//  OpenResolverEx —— IOpenResolverEx
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenResolver/OpenResolver.sol";
import "OpenNFTs/contracts/interfaces/IOpenResolverEx.sol";

contract OpenResolverEx is IOpenResolverEx, OpenResolver {
    function initialize(address owner_) external override(IOpenResolverEx) {
        OpenERC173._initialize(owner_);
    }

    function supportsInterface(bytes4 interfaceId) public view override(OpenResolver) returns (bool) {
        return interfaceId == type(IOpenResolverEx).interfaceId || super.supportsInterface(interfaceId);
    }
}
