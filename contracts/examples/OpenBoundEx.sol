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
//  OpenERC165 (supports)
//      |
//      ——————————————————————————————————————————————
//      |                 |             |            |
//  OpenERC721 (NFT)  OpenERC173  OpenChecker  OpenCloneable
//      |             (ownable)         |            |
//      |                 |             |            |
//  OpenERC5192      OpenPauseable      |            |
//  (SoulBound)           |             |            |
//      |                 |             |            |
//      ——————————————————————————————————————————————
//      |
//  OpenBound --- IOpenBoundEx --- IERC721Enumerable --- IERC721Metadata
//
pragma solidity 0.8.9;

import "OpenNFTs/contracts/OpenResolver/OpenChecker.sol";
import "OpenNFTs/contracts/OpenNFTs/OpenPauseable.sol";
import "OpenNFTs/contracts/OpenCloner/OpenCloneable.sol";
import "OpenNFTs/contracts/OpenERC/OpenERC5192.sol";

import "OpenNFTs/contracts/examples/IOpenBoundEx.sol";
import "OpenNFTs/contracts/interfaces/IOpenCloneable.sol";
import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IERC721Metadata.sol";
import "OpenNFTs/contracts/libraries/Bafkrey.sol";

/// @title OpenBound smartcontract
/// limited to one nft per address
contract OpenBoundEx is
    IOpenBoundEx,
    IERC721Enumerable,
    IERC721Metadata,
    OpenCloneable,
    OpenChecker,
    OpenPauseable,
    OpenERC5192
{
    uint256 public maxSupply;

    string public name;
    string public symbol;

    mapping(address => uint256) private _tokenOfOwner;
    mapping(address => uint256) private _tokenIndexOfOwner;
    mapping(uint256 => uint256) private _cidOfToken;
    uint256[] private _tokens;

    string private constant _BASE_URI = "ipfs://";

    function mint(uint256 cid)
        external
        override (IOpenBoundEx)
        onlyWhenNotPaused
        returns (uint256 tokenID)
    {
        tokenID = OpenBoundEx._mint(msg.sender, cid);
    }

    function claim(uint256 tokenID, uint256 cid)
        external
        override (IOpenBoundEx)
        onlyWhenNotPaused
    {
        require(tokenID == _tokenID(msg.sender, cid), "Not owner");
        OpenBoundEx._mint(msg.sender, cid);
    }

    function burn(uint256 tokenID) external override (IOpenBoundEx) {
        address from = ownerOf(tokenID);
        require(from == msg.sender, "Not owner");

        _burn(tokenID);
    }

    function getMyTokenID(uint256 cid)
        external
        view
        override (IOpenBoundEx)
        returns (uint256 myTokenID)
    {
        myTokenID = _tokenID(msg.sender, cid);
    }

    function getCID(uint256 tokenID) external view override (IOpenBoundEx) returns (uint256 cid) {
        cid = _cidOfToken[tokenID];
    }

    /// IERC721Enumerable
    function totalSupply()
        external
        view
        override (IERC721Enumerable)
        returns (uint256 tokensLength)
    {
        tokensLength = _tokens.length;
    }

    function tokenOfOwnerByIndex(address tokenOwner, uint256 index)
        external
        view
        override (IERC721Enumerable)
        returns (uint256 tokenID)
    {
        require(index == 0 && balanceOf(tokenOwner) == 1, "Invalid index");

        tokenID = _tokenOfOwner[tokenOwner];
    }

    function tokenByIndex(uint256 index)
        external
        view
        override (IERC721Enumerable)
        returns (uint256 tokenID)
    {
        require(index < _tokens.length, "Invalid index");

        tokenID = _tokens[index];
    }

    /// IERC721Metadata
    function tokenURI(uint256 tokenID)
        external
        view
        override (IERC721Metadata)
        existsToken(tokenID)
        returns (string memory)
    {
        return _tokenURI(_cidOfToken[tokenID]);
    }

    function getTokenID(address addr, uint256 cid)
        external
        pure
        override (IOpenBoundEx)
        returns (uint256 tokenID)
    {
        tokenID = _tokenID(addr, cid);
    }

    /// IOpenBoundEx
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        uint256 maxSupply_
    ) public override (IOpenBoundEx) {
        OpenCloneable._initialize("OpenBound", 1);
        OpenERC173._initialize(owner_);

        name = name_;
        symbol = symbol_;
        maxSupply = maxSupply_;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        bytes memory params_
    ) public override (OpenCloneable) {
        initialize(name_, symbol_, owner_, abi.decode(params_, (uint256)));
    }

    /// IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override (OpenPauseable, OpenCloneable, OpenERC5192, OpenChecker)
        returns (bool)
    {
        return interfaceId == type(IOpenBoundEx).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function _mint(address to, uint256 cid) internal returns (uint256 tokenID) {
        require((maxSupply == 0) || _tokens.length < maxSupply, "Max supply reached");
        require(balanceOf(to) == 0, "Already minted or claimed");

        tokenID = _tokenID(to, cid);

        _tokens.push(tokenID);
        _tokenOfOwner[to] = tokenID;
        _tokenIndexOfOwner[to] = _tokens.length - 1;
        _cidOfToken[tokenID] = cid;

        OpenBoundEx._mint(to, _tokenURI(cid), tokenID);
    }

    function _mint(address to, string memory newTokenURI, uint256 tokenID)
        internal
        override (OpenERC5192)
    {
        super._mint(to, newTokenURI, tokenID);
    }

    function _burn(uint256 tokenID) internal override (OpenERC721) {
        address from = ownerOf(tokenID);
        uint256 index = _tokenIndexOfOwner[from];
        uint256 lastIndex = _tokens.length - 1;

        if (index != lastIndex) {
            _tokens[index] = _tokens[lastIndex];
            _tokenIndexOfOwner[ownerOf(_tokens[lastIndex])] = index;
        }
        _tokens.pop();

        delete _cidOfToken[tokenID];
        delete _tokenIndexOfOwner[from];
        delete _tokenOfOwner[from];

        super._burn(tokenID);
    }

    function _transferFromBefore(
        address from,
        address to,
        uint256 // tokenId
    ) internal pure override (OpenERC721) {
        require(from == address(0) || to == address(0), "Non transferable NFT");
    }

    function _tokenID(address addr, uint256 cid) private pure returns (uint256 tokenID) {
        tokenID = uint256(keccak256(abi.encodePacked(cid, addr)));
    }

    function _tokenURI(uint256 cid) private pure returns (string memory) {
        return string(abi.encodePacked(_BASE_URI, Bafkrey.uint256ToCid(cid)));
    }
}
