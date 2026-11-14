
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ERC4626Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";

import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {
    UUPSUpgradeable
} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {
    IERC20
} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is
    ERC4626Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20 asset_,
        address initialOwner
    ) external initializer {
        __ERC20_init("Vault Tokenized Share", "vVTK");
        __ERC4626_init(asset_);
        __Ownable_init(initialOwner);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
