
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {VTK} from "../src/VTK.sol";

contract VTKTest is Test {
    VTK public vtk;

    address public alice = address(1);

    function setUp() public {
        vtk = new VTK();
    }

    function test_InitialSupply() public view {
        assertEq(
            vtk.balanceOf(address(vtk)),
            1_000_000 ether
        );
        assertEq(vtk.totalSupply(), 1_000_000 ether);
    }

    function test_BuyVTK() public {
        uint256 amount = 100 ether;

        vm.deal(alice, amount);

        vm.prank(alice);
        vtk.buyVTK{value: amount}();

        assertEq(vtk.balanceOf(alice), amount);
        assertEq(vtk.balanceOf(address(vtk)), 999_900 ether);
        assertEq(address(vtk).balance, amount);
        assertEq(alice.balance, 0);
    }

    function test_SellVTK() public {
        uint256 amount = 100 ether;

        vm.deal(alice, amount);

        vm.prank(alice);
        vtk.buyVTK{value: amount}();

        vm.prank(alice);
        vtk.sellVTK(amount);

        assertEq(vtk.balanceOf(alice), 0);
        assertEq(vtk.balanceOf(address(vtk)), 1_000_000 ether);
        assertEq(address(vtk).balance, 0);
        assertEq(alice.balance, amount);
    }

    function test_RevertWhenBuyingZero() public {
        vm.expectRevert("Amount must be greater than zero");

        vtk.buyVTK();
    }

    function test_RevertWhenSellingZero() public {
        vm.expectRevert("Amount must be greater than zero");

        vtk.sellVTK(0);
    }

    function test_RevertWhenSellingMoreThanBalance() public {
        vm.prank(alice);

        vm.expectRevert("Not enough VTK available");

        vtk.sellVTK(100 ether);
    }

    function test_RevertWhenBuyingMoreThanAvailable() public {
        uint256 amount = 1_000_001 ether;

        vm.deal(alice, amount);

        vm.prank(alice);

        vm.expectRevert("Not enough VTK available");

        vtk.buyVTK{value: amount}();
    }
}
