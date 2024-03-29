// SPDX-License-Identifier: MITs
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
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/tests/examples/OpenAutoMarketEx.sol";
import "OpenNFTs/tests/OpenAutoMarketEx/OpenAutoMarketExHackTest.t.sol";
import "OpenNFTs/tests/OpenAutoMarketEx/OpenAutoMarketExMintTest.t.sol";

import "OpenNFTs/tests/units/ERC165Test.t.sol";
import "OpenNFTs/tests/units/ERC173Test.t.sol";
import "OpenNFTs/tests/units/ERC721Test.t.sol";
import "OpenNFTs/tests/units/ERC721TransferableTest.t.sol";
import "OpenNFTs/tests/units/ERC2981Test.t.sol";
import "OpenNFTs/tests/units/OpenMarketableTest.t.sol";

import "OpenNFTs/tests/interfaces/ITest.sol";

contract OpenAutoMarketExTest is
  ITest,
  ERC165Test,
  ERC173Test,
  ERC721Test,
  ERC721TransferableTest,
  ERC2981Test,
  OpenMarketableTest,
  OpenAutoMarketExHackTest,
  OpenAutoMarketExMintTest
{
  string private constant _TOKEN_URI =
    "ipfs://bafkreidfhassyaujwpbarjwtrc6vgn2iwfjmukw3v7hvgggvwlvdngzllm";

  receive() external payable {}

  function constructorTest(address owner)
    public
    override(
      ERC165Test,
      ERC173Test,
      ERC721Test,
      ERC721TransferableTest,
      ERC2981Test,
      OpenMarketableTest,
      OpenAutoMarketExHackTest,
      OpenAutoMarketExMintTest
    )
    returns (address)
  {
    OpenAutoMarketEx collection = new OpenAutoMarketEx();
    vm.prank(owner);
    collection.initialize(owner, payable(makeAddr("treasury")), 90, true);
    return address(collection);
  }

  function mintTest(address collection, address minter)
    public
    override(
      ERC721Test,
      ERC721TransferableTest,
      ERC2981Test,
      OpenMarketableTest,
      OpenAutoMarketExHackTest,
      OpenAutoMarketExMintTest
    )
    returns (uint256 tokenID, string memory tokenURI)
  {
    tokenURI = _TOKEN_URI;
    vm.prank(minter);
    tokenID = OpenAutoMarketEx(payable(collection)).mint(tokenURI);
  }

  function burnTest(address collection, uint256 tokenID) public override(ERC721Test) {
    vm.prank(OpenAutoMarketEx(payable(collection)).ownerOf(tokenID));
    OpenAutoMarketEx(payable(collection)).burn(tokenID);
  }

  function setPriceTest(address collection, uint256 tokenID, uint256 price) public {
    OpenAutoMarketEx(payable(collection)).setTokenPrice(tokenID, price);
  }

  function setRoyaltyTest(address collection, address receiver, uint96 fee)
    public
    override(ERC2981Test, OpenMarketableTest)
    returns (uint256 tokenID)
  {
    vm.startPrank(OpenAutoMarketEx(payable(collection)).owner());
    (tokenID,) = (OpenAutoMarketEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
    OpenAutoMarketEx(payable(collection)).setTokenRoyalty(tokenID, receiver, fee);
    vm.stopPrank();
  }

  function setUp() public override(ITest) {
    setUpERC165();
    setUpERC721();
    setUpERC173();
    setUpERC2981();
    setUpMarketable();
    setUpERC721Transferable();
    setUpOpenAutoMarketExHack();
    setUpOpenAutoMarketExMint();
  }
}
