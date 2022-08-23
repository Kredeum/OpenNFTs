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
    mapping(address => bool) public isRegistered;
    address[] private _addresses;
    address private _registerer;

    /// @notice onlyRegisterer, by default owner is registerer and can add addresses, can be overriden
    modifier onlyRegisterer() virtual {
        require(msg.sender == owner() || msg.sender == _registerer, "Not registerer");
        _;
    }

    /// @notice isValid, by default all addresses valid
    modifier onlyValid(address) virtual {
        _;
    }

    function setRegisterer(address registerer_) external override(IOpenRegistry) onlyOwner {
        _registerer = registerer_;
    }

    function addAddresses(address[] memory addrs) external override(IOpenRegistry) {
        for (uint256 i = 0; i < addrs.length; i++) {
            _addAddress(addrs[i]);
        }
    }

    function addAddress(address addr) external override(IOpenRegistry) {
        _addAddress(addr);
    }

    function removeAddress(uint256 index) external override(IOpenRegistry) {
        _removeAddress(index);
    }

    function countAddresses() external view override(IOpenRegistry) returns (uint256) {
        return _addresses.length;
    }

    function getAddresses() public view override(IOpenRegistry) returns (address[] memory) {
        return _addresses;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(OpenERC173) returns (bool) {
        return interfaceId == type(IOpenRegistry).interfaceId || super.supportsInterface(interfaceId);
    }

    function _addAddress(address addr) private onlyRegisterer onlyValid(addr) {
        require(!isRegistered[addr], "Already registered");

        _addresses.push(addr);
        isRegistered[addr] = true;
    }

    function _removeAddress(uint256 index) private onlyRegisterer {
        require(index < _addresses.length, "Invalid index");
        require(isRegistered[_addresses[index]], "Not registered");

        delete (isRegistered[_addresses[index]]);
        if (index != _addresses.length - 1) _addresses[index] = _addresses[_addresses.length - 1];
        _addresses.pop();
    }
}
