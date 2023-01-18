// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/Math.sol";

contract MockMath {
    function divOut(uint256 a, uint256 b) external pure returns (uint256) {
        return Math.divOut(a, b);
    }

    function divOut(int256 a, int256 b) external pure returns (int256) {
        return Math.divOut(a, b);
    }

    function sign(int256 a) external pure returns (int256) {
        return Math.sign(a);
    }
}
