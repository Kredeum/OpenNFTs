// SPDX-License-Identifier: MIT
//
// EIP-1167: Minimal Proxy Contract
// https://eips.ethereum.org/EIPS/eip-1167
//
// Derived from OpenZeppelin Contracts (proxy/Clones.sol)
// https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/proxy/Clones.sol
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
//  OpenCloner
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/interfaces/IOpenCloner.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC165.sol";

abstract contract OpenCloner is IOpenCloner, OpenERC165 {
    /// @notice Clone template (via EIP-1167)
    /// @param  template_ : template address
    /// @return clone_ : clone address
    function clone(address template_) external returns (address clone_) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, template_))
            mstore(
                add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            clone_ := create(0, ptr, 0x37)
        }
        assert(clone_ != address(0));
    }

    function parent(address clone_) external view returns (address parent_) {
        // eip1167 deployed code = 45 bytes = 10 bytes + 20 bytes address + 15 bytes
        // extract bytes 10 to 30: shift 2 bytes (16 bits) then truncate to address 20 bytes (uint160)
        return
            (clone_.code.length == 45)
            ? address(uint160(uint256(bytes32(clone_.code)) >> 16))
            : address(0);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (OpenERC165)
        returns (bool)
    {
        return interfaceId == type(IOpenCloner).interfaceId || super.supportsInterface(interfaceId);
    }
}
