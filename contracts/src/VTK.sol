
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VTK is ERC20 {
    constructor() ERC20("Vault Token", "VTK") {
        _mint(address(this), 1_000_000 * 10 ** decimals());
    }

    function buyVTK() external payable {
        require(msg.value > 0, "Amount must be greater than zero");

        uint256 vtkAmount = msg.value;

        require(
            balanceOf(address(this)) >= vtkAmount,
            "Not enough VTK available"
        );

        _transfer(address(this), msg.sender, vtkAmount);
    }

    function sellVTK(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        require(
            balanceOf(msg.sender) >= amount,
            "Not enough VTK available"
        );

        require(
            address(this).balance >= amount,
            "Not enough ETH available"
        );

        _transfer(msg.sender, address(this), amount);

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
