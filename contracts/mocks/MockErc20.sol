// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {SolmateERC20} from "contracts/mocks/SolmateERC20.sol";

interface IMockERC20 {
    function mint(address to, uint256 value) external;
    function burn(address from, uint256 value) external;
}

contract MockERC20 is SolmateERC20, IMockERC20 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_)
        SolmateERC20(name_, symbol_, decimals_)
    {}

    function mint(address to, uint256 value) public virtual override (IMockERC20) {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual override (IMockERC20) {
        _burn(from, value);
    }
}
