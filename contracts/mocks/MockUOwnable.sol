// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../unstructured/UOwnable.sol";

contract MockUOwnable is UOwnable {
    function __initialize() external {
        super.__UOwnable__initialize();
    }
}
