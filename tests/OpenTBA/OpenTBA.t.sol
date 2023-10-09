// SPDX-License-Identifier: MIT
//
// Derived from ERC6551Account reference implementation `SimpleERC6551Account.sol`
// https://github.com/erc6551/reference/blob/main/src/examples/simple/SimpleERC6551Account.sol
//
pragma solidity ^0.8.0;

import {OpenTBA} from "contracts/OpenTBA/OpenTBA.sol";
import {DeployAll} from "script/DeployAll.s.sol";
import {ERC6551Registry} from "erc6551/src/ERC6551Registry.sol";
import {MockERC20} from "contracts/mocks/MockERC20.sol";

import {console} from "forge-std/console.sol";

contract OpenTBATest is OpenTBA, DeployAll {
  ERC6551Registry registry;
  OpenTBA openTBA;
  address collection;
  address implementation;
  address nftOwner;

  uint256 chainId;
  uint256 tokenId = 0;
  uint256 salt = 42;

  function setUp() public {
    console.log(msg.sender, "setUp ~ msg.sender");

    chainId = block.chainid;

    collection = deploy("OpenNFTsSimpleEx");
    registry = ERC6551Registry(deploy("ERC6551Registry"));
    implementation = deploy("OpenTBA");

    registry.createAccount(implementation, chainId, collection, tokenId, salt, "");
    openTBA = OpenTBA(payable(registry.account(implementation, chainId, collection, tokenId, salt)));

    nftOwner = openTBA.owner();
    assert(nftOwner == msg.sender);
  }

  function test_OpenTBA_OK() public pure {
    assert(true);
  }

  function test_OpenTBA_Create() public {
    address account = registry.account(implementation, chainId, collection, tokenId, salt);

    if (account.code.length == 0) {
      registry.createAccount(implementation, chainId, collection, tokenId, salt, "");
    }
    assert(account.code.length != 0);
  }

  function test_OpenTBA_token() public view {
    (uint256 chId, address coll, uint256 tokId) = OpenTBA(payable(openTBA)).token();

    assert(chId == chainId);
    assert(coll == collection);
    assert(tokId == tokenId);
  }

  function test_OpenTBA_delegatecall() public {
    assert(true);
  }

  function test_OpenTBA_call() public  {
    uint256 amount = 1; // 2e18;
    address to = makeAddr("to");

    MockERC20 mockERC20 = new MockERC20("Test", "TT", 18);
    mockERC20.mint(address(openTBA), amount);

    assert(mockERC20.balanceOf(address(openTBA)) == amount);

    bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);

    vm.prank(nftOwner);
    openTBA.execute(address(mockERC20), 0, data, 0);

    assert(mockERC20.balanceOf(address(openTBA)) == 0);
    assert(mockERC20.balanceOf(to) == amount);
  }
}
