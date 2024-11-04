// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/OwnerWithdrawable.sol";
import "./MockOwnable.sol";

contract MockOwnerWithdrawable is MockOwnable, OwnerWithdrawable {
    function withdraw(address token, uint256 amount) public override(OwnerWithdrawable) {
        super.withdraw(token, amount);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}
