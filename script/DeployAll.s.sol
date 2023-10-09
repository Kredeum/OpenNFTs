// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployOpenNFTsSimpleEx} from "./deploy/00_DeployOpenNFTsSimpleEx.s.sol";
import {DeployERC6551Registry} from "./deploy/01_DeployERC6551Registry.s.sol";
import {DeployOpenTBA} from "./deploy/02_DeployOpenTBA.s.sol";

contract DeployAll is DeployOpenNFTsSimpleEx, DeployERC6551Registry, DeployOpenTBA {
  function run() public override(DeployOpenNFTsSimpleEx, DeployERC6551Registry, DeployOpenTBA) {
    deploy("OpenNFTsSimpleEx");
    deploy("ERC6551Registry");
    deploy("OpenTBA");
  }
}
