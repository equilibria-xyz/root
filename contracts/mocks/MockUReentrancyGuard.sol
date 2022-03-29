// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../unstructured/UReentrancyGuard.sol";

contract MockUReentrancyGuard is UReentrancyGuard {
    bytes32 private constant STATUS_SLOT = keccak256("equilibria.root.UReentrancyGuard.status");

    event NoOp();

    function __initialize() external initializer {
        super.__UReentrancyGuard__initialize();
    }

    function __status() external view returns (uint256 result) {
        bytes32 slot = STATUS_SLOT;
        assembly {
            result := sload(slot)
        }
    }

    function noReenter() public nonReentrant { emit NoOp(); }
    function reenterRecursive() public nonReentrant { reenterRecursive(); }
    function reenterDifferent() external nonReentrant { noReenter(); }
}
