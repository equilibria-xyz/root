// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Version } from "../types/Version.sol";

interface IInitializable {
    // sig: 0xd6f0e837
    /// @custom:error Contract is already initialized
    error InitializableAlreadyInitializedError();

    // sig: 0xb9a621e1
    /// @custom:error Contract is not initializing
    error InitializableNotInitializingError();

    event Initialized();

    // TODO: Should we omit it from the interface such that the no-op implementation
    // in Initializable quietly handles unversioned use cases?
    // Or Should we remove the no-op implementation instead?

    /// @dev Subclasses must use this function to implement upgrade logic, and
    /// are required to pass `version` to the `initializer` modifier.
    /// The `initializer` modifier will execute the function iff the passed version
    /// matches the immutable version defined in the contract's constructor.
    /// @param version Deployment version this initializer was meant for.  If version
    ///                does not match the contract's version, the initializer will be skipped.
    /// @param initParams Contract-specific parameters to be passed to the initializer.
    function initialize(Version memory version, bytes memory initParams) external;
}
