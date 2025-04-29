// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IImmutable {
    // sig: TODO
    /// @custom:error Constructor version mismatch
    error ImmutableConstructorVersionError();
}
