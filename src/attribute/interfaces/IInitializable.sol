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

    event Initialized(Version version);

    /// @dev Subclasses must use this function to implement upgrade logic, and
    /// are required to pass `version` to the `initializer` modifier.
    /// The `initializer` modifier will execute the function iff the passed version
    /// matches the immutable version defined in the contract's constructor.
    /// @param initParams Contract-specific parameters to be passed to the initializer.
    function initialize(bytes memory initParams) external;

    /// @dev Returns the version of the contract.
    function version() external view returns (Version);

    /// @dev Returns the target version of the contract.
    function target() external view returns (Version);
}
