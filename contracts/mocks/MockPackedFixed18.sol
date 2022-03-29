// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/PackedFixed18.sol";

contract MockPackedFixed18 {
    function MAX() external pure returns (PackedFixed18) {
        return PackedFixed18Lib.MAX;
    }

    function MIN() external pure returns (PackedFixed18) {
        return PackedFixed18Lib.MIN;
    }

    function unpack(PackedFixed18 a) external pure returns (Fixed18) {
        return PackedFixed18Lib.unpack(a);
    }
}
