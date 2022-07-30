// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenNFTsEx {
    function initialize(
        string memory name,
        string memory symbol,
        address owner,
        bool[] memory options
    ) external;

    function mint(string memory jsonURI) external returns (uint256 tokenID);

    function open() external view returns (bool);
}
