// SPDX-License-Identifier: MIT
//
// Derived from Kredeum NFTs
// https://github.com/Kredeum/kredeum
//
//       ___           ___         ___           ___                    ___           ___                     ___
//      /  /\         /  /\       /  /\         /__/\                  /__/\         /  /\        ___        /  /\
//     /  /::\       /  /::\     /  /:/_        \  \:\                 \  \:\       /  /:/_      /  /\      /  /:/_
//    /  /:/\:\     /  /:/\:\   /  /:/ /\        \  \:\                 \  \:\     /  /:/ /\    /  /:/     /  /:/ /\
//   /  /:/  \:\   /  /:/~/:/  /  /:/ /:/_   _____\__\:\            _____\__\:\   /  /:/ /:/   /  /:/     /  /:/ /::\
//  /__/:/ \__\:\ /__/:/ /:/  /__/:/ /:/ /\ /__/::::::::\          /__/::::::::\ /__/:/ /:/   /  /::\    /__/:/ /:/\:\
//  \  \:\ /  /:/ \  \:\/:/   \  \:\/:/ /:/ \  \:\~~\~~\/          \  \:\~~\~~\/ \  \:\/:/   /__/:/\:\   \  \:\/:/~/:/
//   \  \:\  /:/   \  \::/     \  \::/ /:/   \  \:\  ~~~            \  \:\  ~~~   \  \::/    \__\/  \:\   \  \::/ /:/
//    \  \:\/:/     \  \:\      \  \:\/:/     \  \:\                 \  \:\        \  \:\         \  \:\   \__\/ /:/
//     \  \::/       \  \:\      \  \::/       \  \:\                 \  \:\        \  \:\         \__\/     /__/:/
//      \__\/         \__\/       \__\/         \__\/                  \__\/         \__\/                   \__\/
//
//
//   OpenERC165
//   (supports)
//       |
//       ———————————————————————————————————————————————————————————————————
//       |                                     |             |             |
//   OpenERC721                           OpenERC173  OpenChecker  OpenCloneable
//     (NFT)                               (ownable)         |             |
//       |                                     |             |             |
//       ————————————————————————————      ——————————        |             |
//       |           |              |      |        |        |             |
//   OpenERC721  OpenERC721   OpenERC2981  |        |        |             |
//    Metadata   Enumerable  (RoyaltyInfo) |        |        |             |
//       |           |              |      |        |        |             |
//       |           |              ————————        |        |             |
//       |           |              |               |        |             |
//       |           |        OpenMarketable  OpenPauseable  |             |
//       |           |              |               |        |             |
//       ———————————————————————————————————————————————————————————————————
//       |
//    OpenNFTs
//       |
//   OpenNFTsEx —— IOpenNFTsEx
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenNFTs/OpenNFTs.sol";
import "OpenNFTs/contracts/examples/IOpenNFTsEx.sol";

/// @title OpenNFTs smartcontract
contract OpenNFTsEx is IOpenNFTsEx, OpenNFTs {
    /// @notice Mint NFT allowed to everyone or only collection owner
    bool public open;

    /// @notice override onlyMinter:
    /// @notice either everybody in open collection,
    /// @notice either only owner in specific collection
    modifier onlyMinter() override (OpenNFTs) {
        require(open || (owner() == msg.sender), "Not minter");
        _;
    }

    function buy(uint256 tokenID) external payable override (IOpenNFTsEx) {
        this.safeTransferFrom{value: msg.value}(ownerOf(tokenID), msg.sender, tokenID);
    }

    function mint(string memory tokenURI)
        external
        override (IOpenNFTsEx)
        onlyMinter
        onlyWhenNotPaused
        returns (uint256)
    {
        return OpenNFTs.mint(msg.sender, tokenURI);
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        address treasury_,
        uint96 treasuryFee_,
        bool[] memory options_
    )
        public
        override (IOpenNFTsEx)
    {
        OpenNFTs._initialize(name_, symbol_, owner_, treasury_, treasuryFee_);
        open = options_[0];
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        bytes memory params_
    )
        public
        override (OpenCloneable)
    {
        (address payable treasury_, uint96 treasuryFee_, bool[] memory options_) =
            abi.decode(params_, (address, uint96, bool[]));
        initialize(name_, symbol_, owner_, treasury_, treasuryFee_, options_);
    }

    function supportsInterface(bytes4 interfaceId) public view override (OpenNFTs) returns (bool) {
        return interfaceId == type(IOpenNFTsEx).interfaceId || super.supportsInterface(interfaceId);
    }
}
