// SPDX-License-Identifier: MIT
//
// Derived from Kredeum NFTs
// https://github.com/Kredeum/kredeum
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
//   OpenERC173
//        |
//  OpenRegistry —— IOpenRegistry
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenERC/OpenERC173.sol";
import "OpenNFTs/contracts/interfaces/IOpenRegistry.sol";
import "forge-std/console.sol";

abstract contract OpenRegistry is IOpenRegistry, OpenERC173 {
    address[] internal _addresses;

    /// @notice onlyRegisterer, by default owner is registerer and can add addresses, can be overriden
    modifier onlyRegisterer() virtual {
        require(msg.sender == owner(), "Not registerer");
        _;
    }

    function addAddresses(address[] memory addrs) external override(IOpenRegistry) onlyRegisterer {
        for (uint256 i = 0; i < addrs.length; i++) {
            _addresses.push(addrs[i]);
        }
    }

    function burnAddress(uint256 index) external override(IOpenRegistry) onlyRegisterer { 
        _addresses[index] = _addresses[_addresses.length - 1];
    }

    function getAddress(uint256 index) external view override(IOpenRegistry) returns (address addr) {
        require(index < _addresses.length, "Invalid index");
        return _addresses[index];
    }

    function countAddresses() external view override(IOpenRegistry) returns (uint256) {
        return _addresses.length;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenERC173) returns (bool) {
        return interfaceId == type(IOpenRegistry).interfaceId || super.supportsInterface(interfaceId);
    }
}
