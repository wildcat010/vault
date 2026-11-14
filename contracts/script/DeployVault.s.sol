
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

import {IERC20} from
    "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC1967Proxy} from
    "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployVault is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(privateKey);
        address vtkAddress = vm.envAddress("VTK_ADDRESS");

        vm.startBroadcast(privateKey);

        Vault implementation = new Vault();

        bytes memory data = abi.encodeCall(
            Vault.initialize,
            (IERC20(vtkAddress), deployer)
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            data
        );

        vm.stopBroadcast();

        string memory json = vm.serializeAddress(
            "deployments",
            "VaultImplementation",
            address(implementation)
        );

        json = vm.serializeAddress(
            "deployments",
            "VaultProxy",
            address(proxy)
        );

        vm.writeJson(
            json,
            string.concat(
                vm.projectRoot(),
                "/broadcast/deployed-addresses.json"
            )
        );
    }
}
