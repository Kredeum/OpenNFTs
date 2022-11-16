// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOpenAutoMarketEx {
    function initialize(address owner, address payable treasury, uint96 treasuryFee, bool minimal)
        external;

    function buy(uint256 tokenID) external payable;

    function mint(string memory tokenURI) external payable returns (uint256);

    function burn(uint256 tokenID) external;

    function getEthBalance(address account) external view returns (uint256);
}
