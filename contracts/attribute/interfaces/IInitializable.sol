// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IInitializable {
    error InitializableZeroVersionError();
    error InitializableAlreadyInitializedError(uint256 version);
    error InitializableNotInitializingError();

    event Initialized(uint256 version);
}
