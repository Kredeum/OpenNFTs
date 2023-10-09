// SPDX-License-Identifier: MIT
//   OpenGuard
//
pragma solidity ^0.8.0;

import {OpenTBA} from "contracts/OpenTBA/OpenTBA.sol";
import {DeployAll} from "script/DeployAll.s.sol";
import {ERC6551Registry} from "erc6551/src/ERC6551Registry.sol";

contract OpenTBATest is OpenTBA, DeployAll {
  ERC6551Registry registry;
  address collection;
  address implementation;
  address openTBA;

  uint256 chainId;
  uint256 tokenId = 1;
  uint256 salt = 42;

  function setUp() public {
    chainId = block.chainid;

    collection = deploy("OpenNFTsSimpleEx");
    registry = ERC6551Registry(deploy("ERC6551Registry"));
    implementation = deploy("OpenTBA");

    openTBA = registry.account(implementation, chainId, collection, tokenId, salt);
    registry.createAccount(implementation, chainId, collection, tokenId, salt, "");
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
}
