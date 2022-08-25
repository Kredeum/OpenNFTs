// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721Infos {
    struct CollectionInfos {
        address collection;
        address owner;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 balanceOf;
        bool[] supported;
    }

    struct NftInfos {
        uint256 tokenID;
        string tokenURI;
        address owner;
        address approved;
    }
}
