// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { Fixed6, Fixed6Lib } from "./Fixed6.sol";

function add(Fixed6 a, Fixed6 b) pure returns (Fixed6) {
    return Fixed6Lib.add(a, b);
}
function sub(Fixed6 a, Fixed6 b) pure returns (Fixed6) {
    return Fixed6Lib.sub(a, b);
}
function mul(Fixed6 a, Fixed6 b) pure returns (Fixed6) {
    return Fixed6Lib.mul(a, b);
}
function div(Fixed6 a, Fixed6 b) pure returns (Fixed6) {
    return Fixed6Lib.div(a, b);
}
function eq(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.eq(a, b);
}
function neq(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.neq(a, b);
}
function gt(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.gt(a, b);
}
function lt(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.lt(a, b);
}
function gte(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.gte(a, b);
}
function lte(Fixed6 a, Fixed6 b) pure returns (bool) {
    return Fixed6Lib.lte(a, b);
}