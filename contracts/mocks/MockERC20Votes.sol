// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract MockERC20Votes is ERC20Votes {
    constructor() ERC20("Mock ERC20 Votes", "MOCK") ERC20Permit("Mock ERC20 Votes") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

