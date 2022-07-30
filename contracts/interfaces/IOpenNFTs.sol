// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenNFTs {
    function initialize(
        string memory name,
        string memory symbol,
        address owner
    ) external;

    function burn(uint256 tokenID) external;

    function buy(uint256 tokenID) external payable;

    function withdraw(address token) external;
}
