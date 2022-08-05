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
//  OpenMarketable —— IOpenMarketable
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenNFTs/OpenMarketable.sol";
import "OpenNFTs/contracts/interfaces/IOpenAutoMarket.sol";

contract OpenAutoMarket is IOpenAutoMarket, OpenMarketable {
    uint256 private _tokenID;

    function mint(string memory tokenURI) external payable override(IOpenAutoMarket) returns (uint256 tokenID) {
        tokenID = _tokenID++;
        _mint(msg.sender, tokenURI, tokenID);
    }

    function burn(uint256 tokenID) external override(IOpenAutoMarket) {
        super._burn(tokenID);
    }

    function buy(uint256 tokenID) external payable override(IOpenAutoMarket) {
        this.safeTransferFrom{ value: msg.value }(ownerOf(tokenID), msg.sender, tokenID);
    }

    function initialize(address owner) public override(IOpenAutoMarket) {
        OpenERC173._initialize(owner);
    }

    function supportsInterface(bytes4 interfaceId) public view override(OpenMarketable) returns (bool) {
        return interfaceId == type(IOpenAutoMarket).interfaceId || super.supportsInterface(interfaceId);
    }
}
