// SPDX-License-Identifier: MIT
//
//    OpenERC165 (supports)
//        |
//  OpenChecker
//        |
//    OpenClonerEx
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenResolver/OpenChecker.sol";
import "OpenNFTs/contracts/OpenCloner/OpenCloner.sol";
import "OpenNFTs/contracts/interfaces/IOpenCloneable.sol";

contract OpenClonerEx is OpenCloner {
    function clone(address template_) public override (OpenCloner) returns (address clone_) {
        clone_ = super.clone(template_);

        bool[] memory options = new bool[](1);
        options[0] = true;
        IOpenCloneable(clone_).initialize(
            "Cloned by OpenClonerEx", "TSTEX", msg.sender, abi.encode(options)
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override (OpenCloner)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
