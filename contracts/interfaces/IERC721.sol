// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)
    external
    payable;

  function safeTransferFrom(address from, address to, uint256 tokenId) external payable;

  function transferFrom(address from, address to, uint256 tokenId) external payable;

  function approve(address to, uint256 tokenId) external;

  function setApprovalForAll(address operator, bool approved) external;

  function balanceOf(address owner) external view returns (uint256 balance);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function getApproved(uint256 tokenId) external view returns (address operator);

  function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Enumerable {
  function totalSupply() external view returns (uint256);

  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

  function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Events {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721Metadata {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721TokenReceiver {
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external
    returns (bytes4);
}