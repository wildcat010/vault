// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployVault is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(privateKey);

        string memory deploymentPath = string.concat(
            vm.projectRoot(),
            "/broadcast/deployed-addresses.json"
        );

        // Read the existing VTK address from the deployment JSON.
        string memory json = vm.readFile(deploymentPath);
        address vtkAddress = vm.parseJsonAddress(json, ".VTK");

        vm.startBroadcast(privateKey);

        // Deploy Vault implementation.
        Vault implementation = new Vault();

        // Initialize the proxy with the existing VTK token.
        bytes memory data = abi.encodeCall(
            Vault.initialize,
            (IERC20(vtkAddress), deployer)
        );

        // Deploy ERC1967 proxy.
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);

        vm.stopBroadcast();

        // Preserve VTK and add the new Vault addresses.
        string memory output = vm.serializeAddress(
            "deployments",
            "VTK",
            vtkAddress
        );

        output = vm.serializeAddress(
            "deployments",
            "VaultImplementation",
            address(implementation)
        );

        output = vm.serializeAddress(
            "deployments",
            "VaultProxy",
            address(proxy)
        );

        vm.writeJson(output, deploymentPath);
    }
}
