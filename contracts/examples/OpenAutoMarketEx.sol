// SPDX-License-Identifier: MIT
//
//   OpenERC165
//   (supports)
//        |
//        ————————————————————————————
//        |            |             |
//   OpenERC721    OpenERC173   OpenERC2981
//      (NFT)      (Ownable)   (RoyaltyInfo)
//        |            |             |
//        ————————————————————————————
//        |
//  OpenMarketable
//        |
//  OpenAutoMarketEx —— IOpenAutoMarketEx
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenNFTs/OpenMarketable.sol";
import "OpenNFTs/contracts/examples/IOpenAutoMarketEx.sol";

contract OpenAutoMarketEx is IOpenAutoMarketEx, OpenMarketable {
    uint256 private _tokenID;

    function mint(string memory tokenURI) external payable override (IOpenAutoMarketEx) returns (uint256 tokenID) {
        tokenID = _tokenID++;
        OpenMarketable._mint(msg.sender, tokenURI, tokenID);
    }

    function burn(uint256 tokenID) external override (IOpenAutoMarketEx) {
        super._burn(tokenID);
    }

    function buy(uint256 tokenID) external payable override (IOpenAutoMarketEx) {
        this.safeTransferFrom{value: msg.value}(ownerOf(tokenID), msg.sender, tokenID);
    }

    function initialize(address owner) public override (IOpenAutoMarketEx) {
        OpenERC173._initialize(owner);
    }

    function supportsInterface(bytes4 interfaceId) public view override (OpenMarketable) returns (bool) {
        return interfaceId == type(IOpenAutoMarketEx).interfaceId || super.supportsInterface(interfaceId);
    }
}
