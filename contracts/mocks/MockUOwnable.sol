// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/UOwnable.sol";

contract MockUOwnable is UOwnable {
    function __initialize() external initializer {
        super.__UOwnable__initialize();
    }
}
