// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/ReentrancyGuard.sol";

contract MockReentrancyGuard is ReentrancyGuard {
    Uint256Storage private constant _status = Uint256Storage.wrap(keccak256("equilibria.root.ReentrancyGuard.status"));

    event NoOp();

    function __initialize() external initializer(1) {
        super.__ReentrancyGuard__initialize();
    }

    function initializeIncorrect() external {
        super.__ReentrancyGuard__initialize();
    }

    function __status() external view returns (uint256) {
        return _status.read();
    }

    function noReenter() public nonReentrant { emit NoOp(); }
    function reenterRecursive() public nonReentrant { reenterRecursive(); }
    function reenterDifferent() external nonReentrant { noReenter(); }
}
