// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IInitializable {
    error UInitializableZeroVersionError();
    error UInitializableAlreadyInitializedError(uint256 version);
    error UInitializableNotInitializingError();

    event Initialized(uint256 version);
}
