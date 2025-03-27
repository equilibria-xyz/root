// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Fixed6, Fixed6Lib } from "../src/number/types/Fixed6.sol";
import { Fixed18, Fixed18Lib } from "../src/number/types/Fixed18.sol";
import { UFixed6, UFixed6Lib } from "../src/number/types/UFixed6.sol";
import { UFixed18, UFixed18Lib } from "../src/number/types/UFixed18.sol";

/// @dev Facilities useful for testing library types, particularly fixed numeric types
contract RootTest is Test {
    function assertFixed6Eq(Fixed6 a, Fixed6 b, string memory message) public pure {
        assertEq(Fixed6.unwrap(a), Fixed6.unwrap(b), message);
    }

    function assertFixed18Eq(Fixed18 a, Fixed18 b, string memory message) public pure {
        assertEq(Fixed18.unwrap(a), Fixed18.unwrap(b), message);
    }

    function assertUFixed6Eq(UFixed6 a, UFixed6 b, string memory message) public pure {
        assertEq(UFixed6.unwrap(a), UFixed6.unwrap(b), message);
    }

    function assertUFixed18Eq(UFixed18 a, UFixed18 b, string memory message) public pure {
        assertEq(UFixed18.unwrap(a), UFixed18.unwrap(b), message);
    }
}
