// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Ownable.sol";

contract MockOwnable is Ownable {
    bool public beforeCalled;

    function __initialize() external initializer(1) {
        super.__UOwnable__initialize();
    }

    function _beforeAcceptOwner() internal override {
        beforeCalled = true;
    }
}
