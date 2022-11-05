// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

interface IERC1155Ex {
    function mint(uint256) external;
}

contract ERC1155Ex is IERC1155Ex, ERC1155 {
    uint256 id;

    constructor() ERC1155("https://erc1155ex.test") {}

    function mint(uint256 amount) public override (IERC1155Ex) {
        _mint(msg.sender, ++id, amount, "");
    }
}
