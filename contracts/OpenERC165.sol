// SPDX-License-Identifier: MIT
//
// Derived from OpenZeppelin Contracts (utils/introspection/ERC165.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/utils/introspection/ERC165.sol
//
//                OpenERC165
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC165Checker.sol";

abstract contract OpenERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165Checker).interfaceId || interfaceId == 0x01ffc9a7; //  type(IERC165).interfaceId
    }

    function checkSupportedInterfaces(bytes4[] memory interfaceIds) external view returns (bool[] memory interfaceIdsChecker) {
        interfaceIdsChecker = new bool[](interfaceIds.length);
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            interfaceIdsChecker[i] = supportsInterface(interfaceIds[i]);
        }
    }
}
