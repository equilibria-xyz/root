// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import { Initializable } from "src/attribute/Initializable.sol";

/// @dev Facilities provided by the proxy
interface IProxy is IERC1967 {
    /// @dev Replaces the implementation, validating name and version
    /// @param newImplementation The new implementation contract
    /// @param initData Calldata to invoke the instance's initializer
    function upgradeToAndCall(
        Initializable newImplementation,
        bytes calldata initData
    ) external payable;

    // TODO: rollback mechanism
}
