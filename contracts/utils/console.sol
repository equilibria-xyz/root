// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

// reference material:
// https://github.com/foundry-rs/forge-std/blob/master/src/console.sol and
// https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol

import { console as hhConsole } from "hardhat/console.sol";

library console {
    /*address constant CONSOLE_ADDRESS =
        0x000000000000000000636F6e736F6c652e6c6f67;

    function _sendLogPayloadImplementation(bytes memory payload) internal view {
        address consoleAddress = CONSOLE_ADDRESS;
        /// @solidity memory-safe-assembly
        assembly {
            pop(
                staticcall(
                    gas(),
                    consoleAddress,
                    add(payload, 32),
                    mload(payload),
                    0,
                    0
                )
            )
        }
    }

    function _castToPure(
      function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }

    function _sendLogPayload(bytes memory payload) internal pure {
        _castToPure(_sendLogPayloadImplementation)(payload);
    }*/

    function itoa(int256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        bool negative = value < 0;
        uint256 v = negative ? uint256(-value) : uint256(value);
        uint256 len = negative ? 2 : 1;

        for (uint256 i = v; i > 0; i /= 10) {
            len++;
        }
        bytes memory bstr = new bytes(len);

        uint256 i = len - 1;
        for (uint256 j = v; j > 0; j /= 10) {
            bstr[i--] = bytes1(uint8(48 + j % 10));
        }
        if (negative) {
            bstr[0] = "-";
        }
        return string(bstr);
    }

    function log(string memory p0, int256 p1) internal view {
        //_sendLogPayload(abi.encodeWithSignature("log(string,int256)", p0, p1));
        hhConsole.log(p0, itoa(p1));
    }

    function log(string memory p0, uint256 p1, uint256 p2) internal view {
        hhConsole.log(p0, p1, p2);
    }

    function log(string memory p0, uint256 p1, int256 p2) internal view {
        hhConsole.log(p0, p1, itoa(p2));
    }

    function log(string memory p0, int256 p1, uint256 p2) internal view {
        hhConsole.log(p0, itoa(p1), p2);
    }

    function log(string memory p0, int256 p1, int256 p2) internal view {
        hhConsole.log(p0, itoa(p1), itoa(p2));
    }
}