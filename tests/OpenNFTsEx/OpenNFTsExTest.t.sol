// SPDX-License-Identifier: MITs
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "OpenNFTs/tests/examples/OpenNFTsEx.sol";

import "OpenNFTs/tests/OpenNFTsEx/OpenNFTsExInitializeTest.t.sol";
import "OpenNFTs/tests/OpenNFTsEx/OpenNFTsExCloneTest.t.sol";
import "OpenNFTs/tests/OpenNFTsEx/OpenNFTsExSupportsTest.t.sol";
import "OpenNFTs/tests/OpenNFTsEx/OpenNFTsExBuyTest.t.sol";

import "OpenNFTs/tests/sets/OpenNFTsTest.t.sol";

import "OpenNFTs/tests/units/ERC721TransferableTest.t.sol";
import "OpenNFTs/tests/units/ERC173Test.t.sol";
import "OpenNFTs/tests/units/ERC2981Test.t.sol";
import "OpenNFTs/tests/units/OpenNFTsBurnTest.t.sol";
import "OpenNFTs/tests/units/OpenNFTsSetupTest.t.sol";
import "OpenNFTs/tests/units/OpenPauseableTest.t.sol";
import "OpenNFTs/tests/units/OpenMarketableTest.t.sol";

contract OpenNFTsExTest is
  ERC721TransferableTest,
  ERC173Test,
  ERC2981Test,
  OpenNFTsExInitializeTest,
  OpenNFTsExCloneTest,
  OpenNFTsExSupportsTest,
  OpenNFTsExBuyTest,
  OpenNFTsTest,
  OpenNFTsBurnTest,
  OpenNFTsSetupTest,
  OpenPauseableTest,
  OpenMarketableTest
{
  function constructorTest(address owner)
    public
    override(
      ERC721TransferableTest,
      ERC173Test,
      ERC2981Test,
      OpenNFTsTest,
      OpenNFTsExSupportsTest,
      OpenNFTsExBuyTest,
      OpenNFTsBurnTest,
      OpenNFTsSetupTest,
      OpenPauseableTest,
      OpenMarketableTest,
      OpenNFTsExCloneTest
    )
    returns (address)
  {
    return constructorTest(owner, true);
  }

  function constructorTest(address owner, bool init)
    public
    override(OpenNFTsExInitializeTest)
    returns (address)
  {
    bool[] memory options = new bool[](2);
    options[0] = true; // open
    options[1] = true; // minimal

    OpenNFTsEx collection = new OpenNFTsEx();
    if (init) {
      vm.prank(owner);
      collection.initialize("OpenERC721Test", "OPTEST", owner, payable(address(0x7)), 0, options);
    }

    return address(collection);
  }

  function mintTest(address collection, address minter)
    public
    override(
      OpenNFTsExBuyTest,
      OpenNFTsTest,
      OpenNFTsBurnTest,
      OpenNFTsSetupTest,
      ERC2981Test,
      OpenPauseableTest,
      OpenMarketableTest,
      ERC721TransferableTest
    )
    returns (uint256, string memory)
  {
    vm.prank(minter);
    return (OpenNFTsEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
  }

  function burnTest(address collection, uint256 tokenID)
    public
    override(OpenNFTsTest, OpenNFTsBurnTest)
  {
    vm.prank(OpenNFTsEx(payable(collection)).ownerOf(tokenID));
    OpenNFTsEx(payable(collection)).burn(tokenID);
  }

  function setPriceTest(address collection, uint256 tokenID, uint256 price) public {
    OpenNFTsEx(payable(collection)).setTokenPrice(tokenID, price);
  }

  function setRoyaltyTest(address collection, address receiver, uint96 fee)
    public
    override(ERC2981Test, OpenMarketableTest)
    returns (uint256 tokenID)
  {
    vm.startPrank(OpenNFTsEx(payable(collection)).owner());
    (tokenID,) = (OpenNFTsEx(payable(collection)).mint(_TOKEN_URI), _TOKEN_URI);
    OpenNFTsEx(payable(collection)).setTokenRoyalty(tokenID, receiver, fee);
    vm.stopPrank();
  }

  function setUp() public {
    setUpERC173();
    setUpERC2981();
    setUpPausable();
    setUpMarketable();
    setUpOpenNFTs("OpenERC721Test", "OPTEST");
    setUpERC721Transferable();
    setUpOpenNFTsBurn();
    setUpOpenNFTsBuy();
    setUpOpenNFTsSetup();
    setUpOpenNFTsExInitialize();
    setUpOpenNFTsExClone();
    setUpOpenNFTsExSupports();
  }
}
