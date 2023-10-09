// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.s.sol";
import {OpenTBA} from "contracts/OpenTBA/OpenTBA.sol";

import {console} from "forge-std/console.sol";

contract DeployOpenTBA is DeployLite {
  function deployOpenTBA() public returns (address) {
    vm.startBroadcast(deployer);
    OpenTBA openTBA = new  OpenTBA();
    vm.stopBroadcast();

    return address(openTBA);
  }

  function run() public virtual {
    deploy("OpenTBA");
  }
}
