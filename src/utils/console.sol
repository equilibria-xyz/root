// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Fixed6, Fixed18 } from "../number/types/Fixed6.sol";
import { UFixed6, UFixed18 } from "../number/types/UFixed6.sol";

// reference material:
// https://github.com/foundry-rs/forge-std/blob/master/src/console.sol and
// https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol

// manual code generation utility: scripts/console_codegen.ts

// solhint-disable-next-line no-console
import { console as fConsole } from "forge-std/console.sol";

// solhint-disable-next-line contract-name-camelcase, contract-name-capwords
library console {
    function itoa(int256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        // Determine length of string and unsigned value
        bool negative = value < 0;
        // Handle corner case where type(int256).min cannot be multiplied by -1
        uint256 v = negative ? (value == type(int256).min ? uint256(type(int256).max) + 1 : uint256(-value)) : uint256(value);
        uint256 len = negative ? 2 : 1;
        uint256 i;
        for (i = v; i > 0; i /= 10) {
            len++;
        }
        bytes memory bstr = new bytes(len);

        // Build the string in reverse order
        i = len - 1;
        for (uint256 j = v; j > 0; j /= 10) {
            bstr[i--] = bytes1(uint8(48 + j % 10));
        }
        if (negative) {
            bstr[0] = "-";
        }
        return string(bstr);
    }

    function ftoa(uint256 value, uint256 decimals) internal pure returns (string memory) {
        if (value == 0) return "0";

        // Split the integer and fractional parts
        uint256 integerPart = value / (10**decimals);
        uint256 fractionalPart = value % (10**decimals);

        // Convert integer part to string
        string memory integerStr = itoa(int256(integerPart));

        // Convert fractional part to string
        bytes memory fractionalStr = new bytes(decimals);
        for (uint256 i = decimals; i > 0; i--) {
            fractionalStr[i - 1] = bytes1(uint8(48 + fractionalPart % 10));
            fractionalPart /= 10;
        }

        // Combine integer and fractional parts
        return string(abi.encodePacked(integerStr, ".", fractionalStr));
    }

    function ftoa(int256 value, uint256 decimals) internal pure returns (string memory) {
        if (value == 0) return "0";

        // Determine sign and unsigned value
        bool negative = value < 0;
        uint256 absValue = negative ? uint256(-value) : uint256(value);

        // Split the integer and fractional parts
        uint256 integerPart = absValue / (10**decimals);
        uint256 fractionalPart = absValue % (10**decimals);

        // Convert integer part to string
        string memory integerStr = itoa(int256(integerPart));

        // Convert fractional part to string
        bytes memory fractionalStr = new bytes(decimals);
        for (uint256 i = decimals; i > 0; i--) {
            fractionalStr[i - 1] = bytes1(uint8(48 + fractionalPart % 10));
            fractionalPart /= 10;
        }

        // Combine integer and fractional parts
        string memory result = string(abi.encodePacked(integerStr, ".", fractionalStr));
        if (negative) result = string(abi.encodePacked("-", result));
        return result;
    }

    // no format string, just values

    function log(string memory p0) internal pure {
        fConsole.logString(p0);
    }

    function log(uint256 p0) internal pure {
        fConsole.logUint(p0);
    }

    function log(int256 p0) internal pure {
        fConsole.logInt(p0);
    }

    function log(UFixed6 p0) internal pure {
        fConsole.log(ftoa(UFixed6.unwrap(p0), 6));
    }

    function log(UFixed18 p0) internal pure {
        fConsole.log(ftoa(UFixed18.unwrap(p0), 18));
    }

    function log(Fixed6 p0) internal pure {
        fConsole.log(ftoa(Fixed6.unwrap(p0), 6));
    }

    function log(Fixed18 p0) internal pure {
        fConsole.log(ftoa(Fixed18.unwrap(p0), 18));
    }

    function log(address p0) internal pure {
        fConsole.logAddress(p0);
    }

    function log(bool p0) internal pure {
        fConsole.logBool(p0);
    }

    // string with one value

    function log(string memory p0, uint256 p1) internal pure {
        fConsole.log(p0, p1);
    }

    function log(string memory p0, int256 p1) internal pure {
        fConsole.log(p0, itoa(p1));
    }

    function log(string memory p0, UFixed6 p1) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6));
    }

    function log(string memory p0, UFixed18 p1) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18));
    }

    function log(string memory p0, Fixed6 p1) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6));
    }

    function log(string memory p0, Fixed18 p1) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18));
    }

    function log(string memory p0, address p1) internal pure {
        fConsole.log(p0, p1);
    }

    function log(string memory p0, bool p1) internal pure {
        fConsole.log(p0, p1);
    }

    // string with two values
    // 2 paramaters of 8 types = 8^2 = 64 methods

    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, uint256 p1, int256 p2) internal pure {
        fConsole.log(p0, p1, itoa(p2));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, int256 p1, uint256 p2) internal pure {
        fConsole.log(p0, itoa(p1), p2);
    }

    function log(string memory p0, int256 p1, int256 p2) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2));
    }

    function log(string memory p0, int256 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, int256 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, int256 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, int256 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, Fixed6 p1, int256 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, UFixed6 p1, int256 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, Fixed18 p1, int256 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, UFixed18 p1, int256 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, address p1, uint256 p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, address p1, int256 p2) internal pure {
        fConsole.log(p0, p1, itoa(p2));
    }

    function log(string memory p0, address p1, Fixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, address p1, UFixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, address p1, Fixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, address p1, UFixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, uint256 p1, address p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, int256 p1, address p2) internal pure {
        fConsole.log(p0, itoa(p1), p2);
    }

    function log(string memory p0, Fixed6 p1, address p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, UFixed6 p1, address p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, Fixed18 p1, address p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, UFixed18 p1, address p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, address p1, address p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, uint256 p1, bool p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, int256 p1, bool p2) internal pure {
        fConsole.log(p0, itoa(p1), p2);
    }

    function log(string memory p0, Fixed6 p1, bool p2) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, UFixed6 p1, bool p2) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2);
    }

    function log(string memory p0, Fixed18 p1, bool p2) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, UFixed18 p1, bool p2) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2);
    }

    function log(string memory p0, address p1, bool p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, bool p1, uint256 p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, bool p1, int256 p2) internal pure {
        fConsole.log(p0, p1, itoa(p2));
    }

    function log(string memory p0, bool p1, Fixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6));
    }

    function log(string memory p0, bool p1, UFixed6 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6));
    }

    function log(string memory p0, bool p1, Fixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18));
    }

    function log(string memory p0, bool p1, UFixed18 p2) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18));
    }

    function log(string memory p0, bool p1, address p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    function log(string memory p0, bool p1, bool p2) internal pure {
        fConsole.log(p0, p1, p2);
    }

    // string with three values
    // 3 paramaters of 8 types = 8^3 = 512 methods
    // generated 512 permutations

    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, uint256 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), itoa(p3));
    }

    function log(string memory p0, uint256 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, uint256 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, uint256 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, uint256 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, uint256 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, itoa(p3));
    }

    function log(string memory p0, int256 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), p3);
    }

    function log(string memory p0, int256 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), itoa(p3));
    }

    function log(string memory p0, int256 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), p3);
    }

    function log(string memory p0, int256 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), p3);
    }

    function log(string memory p0, int256 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, itoa(p3));
    }

    function log(string memory p0, int256 p1, address p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, itoa(p3));
    }

    function log(string memory p0, int256 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, p3);
    }

    function log(string memory p0, int256 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, int256 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, int256 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, int256 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, int256 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, int256 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, int256 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, int256 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, int256 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, itoa(p1), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, address p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), itoa(p3));
    }

    function log(string memory p0, address p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, address p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, address p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, address p1, address p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, address p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, address p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, address p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, address p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, address p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, address p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, address p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, address p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, address p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, bool p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), itoa(p3));
    }

    function log(string memory p0, bool p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, bool p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), p3);
    }

    function log(string memory p0, bool p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, p1, p2, itoa(p3));
    }

    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, p1, p2, p3);
    }

    function log(string memory p0, bool p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, bool p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, bool p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, bool p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, bool p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, bool p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, bool p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, bool p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, bool p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, p1, ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, UFixed6 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, UFixed6 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, UFixed6 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, address p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, UFixed6 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed6 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, UFixed18 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, UFixed18 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, UFixed18 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, address p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, UFixed18 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, UFixed18 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(UFixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, Fixed6 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, Fixed6 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), p3);
    }

    function log(string memory p0, Fixed6 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, address p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, p3);
    }

    function log(string memory p0, Fixed6 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed6 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed6.unwrap(p1), 6), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, uint256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, int256 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, Fixed18 p1, int256 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, int256 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, Fixed18 p1, int256 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), p3);
    }

    function log(string memory p0, Fixed18 p1, int256 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, int256 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, int256 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, int256 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), itoa(p2), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, address p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, address p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, address p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, address p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, address p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, address p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, address p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, address p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, bool p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, bool p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, bool p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, bool p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, p3);
    }

    function log(string memory p0, Fixed18 p1, bool p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, bool p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, bool p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, bool p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), p2, ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, UFixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, UFixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(UFixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, Fixed6 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed6.unwrap(p2), 6), ftoa(Fixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, uint256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, int256 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), itoa(p3));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, address p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, bool p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), p3);
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, UFixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, UFixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(UFixed18.unwrap(p3), 18));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, Fixed6 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed6.unwrap(p3), 6));
    }

    function log(string memory p0, Fixed18 p1, Fixed18 p2, Fixed18 p3) internal pure {
        fConsole.log(p0, ftoa(Fixed18.unwrap(p1), 18), ftoa(Fixed18.unwrap(p2), 18), ftoa(Fixed18.unwrap(p3), 18));
    }
}
