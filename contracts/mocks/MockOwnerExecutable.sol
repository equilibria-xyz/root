// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { OwnerExecutable } from "../attribute/OwnerExecutable.sol";
import { MockOwnable, Ownable } from "./MockOwnable.sol";

contract MockOwnerExecutable is MockOwnable, OwnerExecutable {
    function execute(address target, bytes calldata data) public payable override(OwnerExecutable) returns (bytes memory result) {
        return super.execute(target, data);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}