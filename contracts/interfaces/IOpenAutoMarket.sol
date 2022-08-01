// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenAutoMarket {
    function initialize(address owner) external;

    function buy(uint256 tokenID) external payable;

    function mint(string memory tokenURI) external returns (uint256);

    function burn(uint256 tokenID) external;
}
