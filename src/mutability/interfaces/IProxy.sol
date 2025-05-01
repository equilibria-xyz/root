// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import { Mutable } from "../Mutable.sol";

/// @dev Facilities provided by the proxy
interface IProxy is IERC1967 {
    /// @dev Replaces the implementation, validating name and version
    /// @param newImplementation The new implementation contract
    /// @param data Calldata to invoke the instance's initializer
    function upgradeToAndCall(Mutable newImplementation, bytes calldata data) external payable;

    /// @dev Prevents any interaction with the proxied contract.
    /// Implementation may be upgraded when paused.
    function pause() external;

    /// @dev Allows interaction with the proxied contract
    function unpause() external;
}
