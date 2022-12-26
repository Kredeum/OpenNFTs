// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IOpenNFTs} from "OpenNFTs/contracts/interfaces/IOpenNFTs.sol";
import {ERC20} from "contracts/mocks/SolmateERC20.sol";
import {IERC20} from "OpenNFTs/contracts/interfaces/IERC20.sol";

contract MockERC20 is SolmateERC20 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_)
        ERC20(name_, symbol_, decimals_)
    {}

    function mint(address to, uint256 value) public virtual override (IOpenNFTs) {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual override (IOpenNFTs) {
        _burn(from, value);
    }
}
