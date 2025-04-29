// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Implementation } from "./Implementation.sol";
import { IImmutable } from "./interfaces/IImmutable.sol";

// TODO
abstract contract Immutable is IImmutable, Implementation {
    uint256 private constant CONSTRUCTOR_VERSION = uint256(keccak256("equilibria.root.Immutable.constructor"));

    constructor(bytes memory data) {
        if (__initialize(data) != CONSTRUCTOR_VERSION) revert ImmutableConstructorVersionError();
    }
}

