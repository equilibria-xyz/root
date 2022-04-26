// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/UReentrancyGuard.sol";

contract MockUReentrancyGuard is UReentrancyGuard {
    Uint256Storage private constant _status = Uint256Storage.wrap(keccak256("equilibria.root.UReentrancyGuard.status"));

    event NoOp();

    function __initialize() external initializer(1) {
        super.__UReentrancyGuard__initialize();
    }

    function __status() external view returns (uint256) {
        return _status.read();
    }

    function noReenter() public nonReentrant { emit NoOp(); }
    function reenterRecursive() public nonReentrant { reenterRecursive(); }
    function reenterDifferent() external nonReentrant { noReenter(); }
}
