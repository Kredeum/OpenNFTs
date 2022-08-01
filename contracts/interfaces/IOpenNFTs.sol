// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenNFTs {
    function initialize(
        string memory name,
        string memory symbol,
        address owner
    ) external;

    function mint(address minter, string memory tokenURI) external returns (uint256 tokenID);

    function burn(uint256 tokenID) external;

    function withdraw(address token) external;
}
