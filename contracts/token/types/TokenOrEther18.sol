// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../../number/types/UFixed18.sol";

/// @dev TokenOrEther18
type TokenOrEther18 is address;
using TokenOrEther18Lib for TokenOrEther18 global;
type TokenOrEther18Storage is bytes32;
using TokenOrEther18StorageLib for TokenOrEther18Storage global;

/**
 * @title TokenOrEther18Lib
 * @notice Library to manage Ether and ERC20s that is compliant with the fixed-decimal types.
 * @dev Normalizes token operations with Ether operations (using a magic Ether address)
 */
library TokenOrEther18Lib {
    using Address for address;
    using SafeERC20 for IERC20;

    error TokenOrEther18PullEtherError();
    error TokenOrEther18ApproveEtherError();

    TokenOrEther18 public constant ZERO = TokenOrEther18.wrap(address(0));
    TokenOrEther18 public constant ETHER = TokenOrEther18.wrap(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE));

    /**
     * @notice Returns whether a token is the Ether address
     * @param self Token to check for
     * @return Whether the token is Ether
     */
    function isEther(TokenOrEther18 self) internal pure returns (bool) {
        return TokenOrEther18.unwrap(self) == TokenOrEther18.unwrap(ETHER);
    }

    /**
     * @notice Returns whether a token is the zero address
     * @param self Token to check for
     * @return Whether the token is the zero address
     */
    function isZero(TokenOrEther18 self) internal pure returns (bool) {
        return TokenOrEther18.unwrap(self) == TokenOrEther18.unwrap(ZERO);
    }

    /**
     * @notice Returns whether the two tokens are equal
     * @param a First token to compare
     * @param b Second token to compare
     * @return Whether the two tokens are equal
     */
    function eq(TokenOrEther18 a, TokenOrEther18 b) internal pure returns (bool) {
        return TokenOrEther18.unwrap(a) ==  TokenOrEther18.unwrap(b);
    }

    /**
     * @notice Approves `grantee` to spend infinite tokens from the caller
     * @dev Uses `approve` rather than `safeApprove` since the race condition
     *      in safeApprove does not apply when going to an infinite approval
     * @param self Token grant approval
     * @param grantee Address to allow spending
     */
    function approve(TokenOrEther18 self, address grantee) internal {
        if (isEther(self)) revert TokenOrEther18ApproveEtherError();
        IERC20(TokenOrEther18.unwrap(self)).approve(grantee, type(uint256).max);
    }

    /**
     * @notice Approves `grantee` to spend `amount` tokens from the caller
     * @dev There are important race conditions to be aware of when using this function
            with values other than 0. This will revert if moving from non-zero to non-zero amounts
            See https://github.com/OpenZeppelin/openzeppelin-contracts/blob/a55b7d13722e7ce850b626da2313f3e66ca1d101/contracts/token/ERC20/IERC20.sol#L57
     * @param self Token grant approval
     * @param grantee Address to allow spending
     * @param amount Amount of tokens to approve to spend
     */
    function approve(TokenOrEther18 self, address grantee, UFixed18 amount) internal {
        if (isEther(self)) revert TokenOrEther18ApproveEtherError();
        IERC20(TokenOrEther18.unwrap(self)).safeApprove(grantee, UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers all held tokens from the caller to the `recipient`
     * @param self Token to transfer
     * @param recipient Address to receive the tokens
     */
    function push(TokenOrEther18 self, address recipient) internal {
        push(self, recipient, balanceOf(self, address(this)));
    }

    /**
     * @notice Transfers `amount` tokens from the caller to the `recipient`
     * @dev IMPORTANT: When transfering ETH, control is transferred to `recipient`, care must
     *      be taken to not create reentrancy vulnerabilities.
     * @param self Token to transfer
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function push(TokenOrEther18 self, address recipient, UFixed18 amount) internal {
        isEther(self)
            ? Address.sendValue(payable(recipient), UFixed18.unwrap(amount))
            : IERC20(TokenOrEther18.unwrap(self)).safeTransfer(recipient, UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to the caller
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param amount Amount of tokens to transfer
     */
    function pull(TokenOrEther18 self, address benefactor, UFixed18 amount) internal {
        if (isEther(self)) revert TokenOrEther18PullEtherError();
        IERC20(TokenOrEther18.unwrap(self)).safeTransferFrom(benefactor, address(this), UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to `recipient`
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function pullTo(TokenOrEther18 self, address benefactor, address recipient, UFixed18 amount) internal {
        if (isEther(self)) revert TokenOrEther18PullEtherError();
        IERC20(TokenOrEther18.unwrap(self)).safeTransferFrom(benefactor, recipient, UFixed18.unwrap(amount));
    }

    /**
     * @notice Returns the name of the token
     * @param self Token to check for
     * @return Token name
     */
    function name(TokenOrEther18 self) internal view returns (string memory) {
        return isEther(self) ? "Ether" : IERC20Metadata(TokenOrEther18.unwrap(self)).name();
    }

    /**
     * @notice Returns the symbol of the token
     * @param self Token to check for
     * @return Token symbol
     */
    function symbol(TokenOrEther18 self) internal view returns (string memory) {
        return isEther(self) ? "ETH" : IERC20Metadata(TokenOrEther18.unwrap(self)).symbol();
    }

    /**
     * @notice Returns the `self` token balance of the caller
     * @param self Token to check for
     * @return Token balance of the caller
     */
    function balanceOf(TokenOrEther18 self) internal view returns (UFixed18) {
        return balanceOf(self, address(this));
    }

    /**
     * @notice Returns the `self` token balance of `account`
     * @param self Token to check for
     * @param account Account to check
     * @return Token balance of the account
     */
    function balanceOf(TokenOrEther18 self, address account) internal view returns (UFixed18) {
        return UFixed18.wrap(
            isEther(self) ?
                account.balance :
                IERC20(TokenOrEther18.unwrap(self)).balanceOf(account)
        );
    }
}

library TokenOrEther18StorageLib {
    function read(TokenOrEther18Storage self) internal view returns (TokenOrEther18 value) {
        assembly ("memory-safe") {
            value := sload(self)
        }
    }

    function store(TokenOrEther18Storage self, TokenOrEther18 value) internal {
        assembly ("memory-safe") {
            sstore(self, value)
        }
    }
}
