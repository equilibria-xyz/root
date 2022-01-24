// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./UFixed18.sol";

/// @dev Token18
type Token18 is address;

/**
 * @title Token18Lib
 * @notice Library to manage 18-decimal ERC20s that is compliant with the fixed-decimal types.
 * @dev Maintains significant gas savings over other Token implementations since no conversion take place
 */
library Token18Lib {
    using UFixed18Lib for UFixed18;
    using SafeERC20 for IERC20;

    uint256 private constant DECIMALS = 18;

    /**
     * @notice Approves `grantee` to spend infinite tokens from the caller
     * @param self Token to transfer
     * @param grantee Address to allow spending
     */
    function approve(Token18 self, address grantee) internal {
        IERC20(Token18.unwrap(self)).safeApprove(grantee, type(uint256).max);
    }

    /**
     * @notice Approves `grantee` to spend `amount` tokens from the caller
     * @param self Token to transfer
     * @param grantee Address to allow spending
     * @param amount Amount of tokens to approve to spend
     */
    function approve(Token18 self, address grantee, UFixed18 amount) internal {
        IERC20(Token18.unwrap(self)).safeApprove(grantee, UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers all held tokens from the caller to the `recipient`
     * @param self Token to transfer
     * @param recipient Address to receive the tokens
     */
    function push(Token18 self, address recipient) internal {
        push(self, recipient, balanceOf(self, address(this)));
    }

    /**
     * @notice Transfers `amount` tokens from the caller to the `recipient`
     * @param self Token to transfer
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function push(Token18 self, address recipient, UFixed18 amount) internal {
        IERC20(Token18.unwrap(self)).safeTransfer(recipient, UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to the caller
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param amount Amount of tokens to transfer
     */
    function pull(Token18 self, address benefactor, UFixed18 amount) internal {
        IERC20(Token18.unwrap(self)).safeTransferFrom(benefactor, address(this), UFixed18.unwrap(amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to `recipient`
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function pullTo(Token18 self, address benefactor, address recipient, UFixed18 amount) internal {
        IERC20(Token18.unwrap(self)).safeTransferFrom(benefactor, recipient, UFixed18.unwrap(amount));
    }

    /**
     * @notice Returns the name of the token
     * @param self Token to check for
     * @return Token name
     */
    function name(Token18 self) internal view returns (string memory) {
        return IERC20Metadata(Token18.unwrap(self)).name();
    }

    /**
     * @notice Returns the symbol of the token
     * @param self Token to check for
     * @return Token symbol
     */
    function symbol(Token18 self) internal view returns (string memory) {
        return IERC20Metadata(Token18.unwrap(self)).symbol();
    }

    /**
     * @notice Returns the decimals of the token
     * @return Token decimals
     */
    function decimals(Token18) internal pure returns (uint256) {
        return DECIMALS;
    }

    /**
     * @notice Returns the `self` token balance of the caller
     * @param self Token to check for
     * @return Token balance of the caller
     */
    function balanceOf(Token18 self) internal view returns (UFixed18) {
        return balanceOf(self, address(this));
    }

    /**
     * @notice Returns the `self` token balance of `account`
     * @param self Token to check for
     * @param account Account to check
     * @return Token balance of the account
     */
    function balanceOf(Token18 self, address account) internal view returns (UFixed18) {
        return UFixed18.wrap(IERC20(Token18.unwrap(self)).balanceOf(account));
    }
}
