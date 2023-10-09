// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {DeployLite} from "forge-deploy-lite/script/DeployLite.s.sol";

import {OpenNFTsSimpleEx} from "contracts/examples/OpenNFTsSimpleEx.sol";

contract DeployOpenNFTsSimpleEx is DeployLite {
  function deployOpenNFTsSimpleEx() public returns (address) {
    vm.startBroadcast(deployer);
    OpenNFTsSimpleEx openNFTsSimpleEx = new OpenNFTsSimpleEx();
    openNFTsSimpleEx.mint("");
    vm.stopBroadcast();

    return address(openNFTsSimpleEx);
  }

  function run() public virtual {
    deploy("OpenNFTsSimpleEx");
  }
}
