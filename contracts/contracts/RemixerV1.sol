// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IZoraCoinV4 {
    //function setPayoutRecipient(address newPayoutRecipient) external;
    function burn(uint256 amount) external;
    function setContractURI(string memory newURI) external;
}

interface SplitsWallet {
    struct Split {
        address[] recipients;
        uint256[] allocations;
        uint256 totalAllocation;
        uint16 distributionIncentive;
    }

    function updateSplit(Split calldata _split) external;
}

contract RemixerV1 is Initializable, OwnableUpgradeable {
    struct CoinData {
        address coin;
        address splitsAddress;
        address[] owners;
        uint16 revenueShare;
        uint16 revenueStack;
    }

    uint256 public totalCoins;
    mapping(address coin => CoinData) public coins;

    error NotACoinOwner(address coin, address owner);

    modifier onlyCoinOwners(address coin) {
        if (!isCoinOwner(coin, msg.sender))
            revert NotACoinOwner(coin, msg.sender);
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) external initializer {
        __Ownable_init(owner);
    }

    function setCoinUri(
        address coin,
        string memory uri
    ) external onlyCoinOwners(coin) {
        IZoraCoinV4 coinContract = IZoraCoinV4(coin);
        coinContract.setContractURI(uri);
    }

    function burn(address coin, uint256 amount) external onlyCoinOwners(coin) {
        IZoraCoinV4 coinContract = IZoraCoinV4(coin);
        coinContract.burn(amount);
    }

    // Add/remove owners
    // Change real coin owner. Maybe for transferring ownership to another contract.

    function isCoinOwner(
        address coin,
        address user
    ) public view returns (bool) {
        // Check it is created
        address[] memory owners = coins[coin].owners;

        for (uint8 i = 0; i < owners.length; i++) {
            if (owners[i] == user) return true;
        }

        return false;
    }
}
