// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault is ERC4626Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    mapping(address => Account) public accounts;

    struct Account {
        uint256 balance;
        uint256 lastAccrualTime;
    }

    event DepositRecorded(
        address indexed receiver,
        uint256 assets,
        uint256 shares,
        uint256 timestamp
    );

    event InterestAccrued(
        address indexed account,
        uint256 interest,
        uint256 newBalance,
        uint256 timestamp
    );

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

    function deposit(
        uint256 assets,
        address receiver
    ) public override returns (uint256 shares) {
        _accrueInterest(receiver);
        shares = super.deposit(assets, receiver);

        uint256 currentBalance = accounts[receiver].balance;

        accounts[receiver] = Account({
            balance: currentBalance + shares,
            lastAccrualTime: block.timestamp
        });

        emit DepositRecorded(receiver, assets, shares, block.timestamp);
    }

    function _accrueInterest(address user) internal {
        Account storage account = accounts[user];

        // No existing balance: initialize the timestamp.
        if (account.balance == 0) {
            account.lastAccrualTime = block.timestamp;
            return;
        }

        uint256 elapsed = block.timestamp - account.lastAccrualTime;

        // Annual compound interest: 3%.
        uint256 interest = (account.balance * 3 * elapsed) / (100 * 365 days);

        account.balance += interest;
        account.lastAccrualTime = block.timestamp;

        emit InterestAccrued(user, interest, account.balance, block.timestamp);
    }
}
