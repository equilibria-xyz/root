// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev Token
type Token is address;
using TokenLib for Token global;

/// @title TokenLib
/// @notice Library to manage ERC20s that is compliant with the fixed-decimal types.
library TokenLib {
    using SafeERC20 for IERC20;

    Token public constant ZERO = Token.wrap(address(0));

    /// @notice Returns whether a token is the zero address
    /// @param self Token to check for
    /// @return Whether the token is the zero address
    function isZero(Token self) internal pure returns (bool) {
        return Token.unwrap(self) == Token.unwrap(ZERO);
    }

    /// @notice Returns whether the two tokens are equal
    /// @param a First token to compare
    /// @param b Second token to compare
    /// @return Whether the two tokens are equal
    function eq(Token a, Token b) internal pure returns (bool) {
        return Token.unwrap(a) ==  Token.unwrap(b);
    }

    /// @notice Approves `grantee` to spend infinite tokens from the caller
    /// @dev Uses `approve` rather than `safeApprove` since the race condition
    ///      in safeApprove does not apply when going to an infinite approval
    /// @param self Token to grant approval
    /// @param self Token to grant approval
    /// @param grantee Address to allow spending
    function approve(Token self, address grantee) internal {
        IERC20(Token.unwrap(self)).approve(grantee, type(uint256).max);
    }

    /// @notice Approves `grantee` to spend `amount` tokens from the caller
    /// @dev There are race conditions to be aware of when using this function
    ///      with values other than 0.
    /// @param self Token to grant approval
    /// @param self Token to grant approval
    /// @param grantee Address to allow spending
    /// @param amount Amount of tokens to approve to spend
    function approve(Token self, address grantee, uint256 amount) internal {
        IERC20(Token.unwrap(self)).approve(grantee, amount);
    }

    /// @notice Transfers all held tokens from the caller to the `recipient`
    /// @param self Token to transfer
    /// @param recipient Address to receive the tokens
    function push(Token self, address recipient) internal {
        push(self, recipient, balanceOf(self, address(this)));
    }

    /// @notice Transfers `amount` tokens from the caller to the `recipient`
    /// @param self Token to transfer
    /// @param recipient Address to transfer tokens to
    /// @param amount Amount of tokens to transfer
    function push(Token self, address recipient, uint256 amount) internal {
        IERC20(Token.unwrap(self)).safeTransfer(recipient, amount);
    }

    /// @notice Transfers `amount` tokens from the `benefactor` to the caller
    /// @dev Reverts if trying to pull Ether
    /// @param self Token to transfer
    /// @param benefactor Address to transfer tokens from
    /// @param amount Amount of tokens to transfer
    function pull(Token self, address benefactor, uint256 amount) internal {
        IERC20(Token.unwrap(self)).safeTransferFrom(benefactor, address(this), amount);
    }

    /// @notice Transfers `amount` tokens from the `benefactor` to `recipient`
    /// @dev Reverts if trying to pull Ether
    /// @param self Token to transfer
    /// @param benefactor Address to transfer tokens from
    /// @param recipient Address to transfer tokens to
    /// @param amount Amount of tokens to transfer
    function pullTo(Token self, address benefactor, address recipient, uint256 amount) internal {
        IERC20(Token.unwrap(self)).safeTransferFrom(benefactor, recipient, amount);
    }

    /// @notice Processes a token transfer based on the sign of the amount
    /// @dev If amount is positive, pulls tokens from the account to the caller
    ///      If amount is negative, pushes tokens from the caller to the account
    /// @param self Token to transfer
    /// @param account Address to pull from or push to
    /// @param amount Signed amount of tokens to transfer
    function update(Token self, address account, int256 amount) internal {
        if (amount < 0) push(self, account, uint256(-amount));
        else if (amount > 0) pull(self, account, uint256(amount));
    }

    /// @notice Returns the name of the token
    /// @param self Token to check for
    /// @return Token name
    function name(Token self) internal view returns (string memory) {
        return IERC20Metadata(Token.unwrap(self)).name();
    }

    /// @notice Returns the symbol of the token
    /// @param self Token to check for
    /// @return Token symbol
    function symbol(Token self) internal view returns (string memory) {
        return IERC20Metadata(Token.unwrap(self)).symbol();
    }

    /// @notice Returns the `self` token balance of the caller
    /// @param self Token to check for
    /// @return Token balance of the caller
    function balanceOf(Token self) internal view returns (uint256) {
        return IERC20(Token.unwrap(self)).balanceOf(address(this));
    }

    /// @notice Returns the `self` token balance of `account`
    /// @param self Token to check for
    /// @param account Account to check
    /// @return Token balance of the account
    function balanceOf(Token self, address account) internal view returns (uint256) {
        return IERC20(Token.unwrap(self)).balanceOf(account);
    }

    /// @notice Returns the `self` total supply
    /// @param self Token to check for
    /// @return The total supply of the token
    function totalSupply(Token self) internal view returns (uint256) {
        return IERC20(Token.unwrap(self)).totalSupply();
    }
}
