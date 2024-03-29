// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC173.sol";
import "OpenNFTs/contracts/interfaces/IERC2981.sol";
import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Metadata.sol";
import "OpenNFTs/contracts/interfaces/IERC721Enumerable.sol";
import "OpenNFTs/contracts/interfaces/IOpenMarketable.sol";

abstract contract OpenNFTsSetupTest is Test {
  address private _collection;
  address private _owner = address(0x1);
  address private _minter = address(0x12);
  address private _buyer = address(0x13);
  address private _tester = address(0x4);
  uint256 private _tokenID0;
  string private _tokenURI0;
  bool[] private _options = new bool[](2);

  function constructorTest(address owner_) public virtual returns (address);

  function mintTest(address collection_, address minter_)
    public
    virtual
    returns (uint256, string memory);

  function setUpOpenNFTsSetup() public {
    _collection = constructorTest(_owner);

    (_tokenID0, _tokenURI0) = mintTest(_collection, _minter);
  }

  function testContract() public {
    assertEq(IERC721Metadata(_collection).name(), "OpenERC721Test");
    assertEq(IERC721Metadata(_collection).symbol(), "OPTEST");
    assertEq(IERC173(_collection).owner(), _owner);
  }

  function testCount() public {
    assertEq(IERC721(_collection).balanceOf(_minter), 1);
    assertEq(IERC721Enumerable(_collection).totalSupply(), 1);
  }

  function testToken() public {
    assertEq(IERC721(_collection).ownerOf(_tokenID0), _minter);
    assertEq(IERC721Enumerable(_collection).tokenByIndex(0), _tokenID0);
    assertEq(IERC721Enumerable(_collection).tokenOfOwnerByIndex(_minter, 0), _tokenID0);
    assertEq(IERC721Metadata(_collection).tokenURI(_tokenID0), _tokenURI0);
  }

  function testPrice() public {
    assertEq(IOpenMarketable(payable(_collection)).getTokenPrice(1), 0);
  }

  function testRoyalties() public {
    (address receiver, uint256 royalties) = IERC2981(_collection).royaltyInfo(1, 1);
    assertEq(receiver, address(0));
    assertEq(royalties, 0);
  }
}
