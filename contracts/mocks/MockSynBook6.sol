// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../synbook/types/SynBook6.sol";

contract MockSynBook6 {
    function compute(SynBook6 memory self, Fixed6 latest, Fixed6 change, UFixed6 price) external pure returns (Fixed6) {
        return SynBook6Lib.compute(self, latest, change, price);
    }
}
