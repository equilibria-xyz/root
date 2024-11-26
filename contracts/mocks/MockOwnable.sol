// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable } from "../attribute/Ownable.sol";

contract MockOwnable is Ownable {
    bool public beforeCalled;

    function __initialize() external initializer(1) {
        super.__Ownable__initialize();
    }

    function __initializeV(uint256 version) external initializer(version) {
        super.__Ownable__initialize();
    }

    function _beforeAcceptOwner() internal virtual override {
        beforeCalled = true;
    }
}
