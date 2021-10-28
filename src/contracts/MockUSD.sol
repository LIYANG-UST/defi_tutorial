// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSD is ERC20("MockUSD", "MUSD") {
    uint256 public constant MOCK_SUPPLY = 1000000e18;

    constructor() {
        // When first deployed, give the owner some coins
        _mint(msg.sender, MOCK_SUPPLY);
    }
}
