
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {VTK} from "../src/VTK.sol";
import {Vault} from "../src/Vault.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC1967Proxy} from
    "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract VaultTest is Test {
    VTK public vtk;
    Vault public vault;

    address public owner = address(1);
    address public alice = address(2);

    function setUp() public {
        vtk = new VTK();

        Vault implementation = new Vault();

        bytes memory data = abi.encodeCall(
            Vault.initialize,
            (IERC20(address(vtk)), owner)
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            data
        );

        vault = Vault(address(proxy));
    }

    function test_Initialization() public view {
        assertEq(address(vault.asset()), address(vtk));
        assertEq(vault.owner(), owner);
        assertEq(vault.name(), "Vault Tokenized Share");
        assertEq(vault.symbol(), "vVTK");
    }

    function test_CannotInitializeTwice() public {
        vm.expectRevert();

        vault.initialize(IERC20(address(vtk)), owner);
    }

    function test_Deposit() public {
        uint256 amount = 100 ether;

        vm.deal(alice, amount);

        vm.prank(alice);
        vtk.buyVTK{value: amount}();

        vm.prank(alice);
        vtk.approve(address(vault), amount);

        vm.prank(alice);
        uint256 shares = vault.deposit(amount, alice);

        assertEq(alice.balance, 0);
        assertEq(vtk.balanceOf(alice), 0);
        assertEq(vault.balanceOf(alice), shares);
        assertEq(vault.balanceOf(alice), amount);
        assertEq(vault.totalAssets(), amount);
    }

    function test_Withdrawal() public {
        uint256 amount = 100 ether;

        vm.deal(alice, amount);

        vm.prank(alice);
        vtk.buyVTK{value: amount}();

        vm.prank(alice);
        vtk.approve(address(vault), amount);

        vm.prank(alice);
        vault.deposit(amount, alice);

        // Alice withdraws VTK from the Vault.
        vm.prank(alice);
        uint256 withdrawnAmount = vault.withdraw(
            amount,
            alice,
            alice
        );

        assertEq(vault.balanceOf(alice), 0);
        assertEq(vault.totalAssets(), 0);
        assertEq(vtk.balanceOf(alice), amount);

        // Alice sells VTK back for ETH.
        vm.prank(alice);
        vtk.sellVTK(withdrawnAmount);

        assertEq(alice.balance, amount);
        assertEq(vtk.balanceOf(alice), 0);
        assertEq(vault.balanceOf(alice), 0);
    }

    function test_RevertWhenWithdrawMoreThanBalance() public {
        uint256 amount = 100 ether;

        vm.deal(alice, amount);

        vm.prank(alice);
        vtk.buyVTK{value: amount}();

        vm.prank(alice);
        vtk.approve(address(vault), amount);

        vm.prank(alice);
        vault.deposit(amount, alice);

        assertEq(vault.balanceOf(alice), amount);
        assertEq(vault.totalAssets(), amount);
        assertEq(vtk.balanceOf(alice), 0);

        vm.expectRevert();
        vm.prank(alice);
        vault.withdraw(101 ether, alice, alice);

        assertEq(vault.balanceOf(alice), amount);
        assertEq(vault.totalAssets(), amount);
        assertEq(vtk.balanceOf(alice), 0);
    }
}
