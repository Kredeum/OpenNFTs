// SPDX-License-Identifier: MIT
//
// Derived from OpenZeppelin Contracts (utils/introspection/ERC165.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/utils/introspection/ERC165.sol
//
//                OpenERC165
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenCheckable.sol";

abstract contract OpenCheckable is OpenERC165, IOpenCheckable {
    function checkSupportedInterfaces(bytes4[] memory interfaceIds)
        external
        view
        returns (bool[] memory interfaceIdsChecker)
    {
        interfaceIdsChecker = new bool[](interfaceIds.length);
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            interfaceIdsChecker[i] = supportsInterface(interfaceIds[i]);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenERC165) returns (bool) {
        return interfaceId == type(IOpenCheckable).interfaceId || super.supportsInterface(interfaceId);
    }
}
