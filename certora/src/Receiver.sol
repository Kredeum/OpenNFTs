// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IReceiver {
    receive() external payable;

    fallback() external payable;

    function sendTo() external payable returns (bool);

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        returns (bytes4);
}

contract Receiver is IReceiver {
    uint256 internal _randNonce = 0;

    receive() external payable override {}

    fallback() external payable override {}

    function sendTo() external payable override returns (bool) {
        // should randomly :
        // 0. revert
        // 1. be ok
        // 2. return false
        uint8 rnd = _randMod(3);
        require(rnd > 0, "sendTo reverts");
        return (rnd == 1);
    }

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        override
        returns (bytes4)
    {
        // should randomly :
        // 0. revert
        // 1. return appropriate value
        // 2. return bad value
        uint8 rnd = _randMod(3);
        require(rnd > 0, "onERC721Received reverts");
        return (rnd == 1) ? this.onERC721Received.selector : bytes4(0x12345678);
    }

    // Generate a random number
    function _randMod(uint256 modulus) internal returns (uint8) {
        return uint8(
            uint256(keccak256(abi.encodePacked(block.number, msg.sender, _randNonce++))) % modulus
        );
    }
}
