// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOpenBoundEx {
  function initialize(string memory name, string memory symbol, address owner, uint256 maxSupply)
    external;

  function mint(uint256 tokenID) external returns (uint256);

  function claim(uint256 tokenID, uint256 cid) external;

  function burn(uint256 tokenID) external;

  function getMyTokenID(uint256 cid) external view returns (uint256);

  function getCID(uint256 tokenID) external view returns (uint256);

  function getTokenID(address addr, uint256 cid) external pure returns (uint256 tokenID);
}
