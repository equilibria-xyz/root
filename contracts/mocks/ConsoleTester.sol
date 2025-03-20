// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { console } from "../utils/console.sol";

contract ConsoleTester {
    function testLogWithInt(int256 signed) external view {
        console.log("      Testing console log of signed int %s with trailing text", signed);
    }

    function testLogWithMultipleInts(int256 signed1, int256 signed2) external view {
        console.log("      Testing both signed, %s and %s", signed1, signed2);
    }
}
