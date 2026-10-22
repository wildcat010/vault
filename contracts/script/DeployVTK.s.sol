
 // SPDX-License-Identifier: MIT
 pragma solidity ^0.8.24;

 import {Script} from "forge-std/Script.sol";
 import {VTK} from "../src/VTK.sol";

 contract DeployVTK is Script {
     function run() external {
         vm.startBroadcast();
         VTK vtk = new VTK();
         vm.stopBroadcast();

         string memory json = vm.serializeAddress("deployments", "VTK", address(vtk));
         vm.writeJson(json, string.concat(vm.projectRoot(), "/broadcast/deployed-addresses.json"));
     }
 }
