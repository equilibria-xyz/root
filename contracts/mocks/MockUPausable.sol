// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/unstructured/UPausable.sol";

contract MockUPausable is UPausable {
    uint256 public counter;

    function __initialize() external initializer(1) {
        super.__UPausable__initialize();
    }

    function increment() external whenNotPaused {
        counter++;
    }

    function incrementNoModifier() external {
        counter++;
    }
}
