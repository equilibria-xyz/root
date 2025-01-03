// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20, ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MockERC20Votes is ERC20Votes {
    constructor() ERC20("Mock ERC20 Votes", "MOCK") ERC20Permit("Mock ERC20 Votes") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

