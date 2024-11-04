// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/OwnerWithdrawable.sol";
import "../token/types/Token18.sol";
import "./MockOwnable.sol";

contract MockOwnerWithdrawable is MockOwnable, OwnerWithdrawable {
    function withdraw(Token18 token) public override(OwnerWithdrawable) {
        super.withdraw(token);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}
