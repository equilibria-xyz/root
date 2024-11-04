// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/OwnerDelegatable.sol";
import "./MockOwnable.sol";

contract MockOwnerDelegatable is MockOwnable, OwnerDelegatable {
    function delegate(IVotes token, address delegatee) public override(OwnerDelegatable) {
        super.delegate(token, delegatee);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}