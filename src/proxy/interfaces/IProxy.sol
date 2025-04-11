// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

/// @dev Facilities provided by the proxy
interface IProxy is IERC1967 {
    /// @dev Emits name and version as event (since it cannot be returned)
    function identify() external;

    /// @dev Replaces the implementation, validating name and version
    function upgradeToAndCall(
        address newImplementation,
        bytes calldata data,
        string calldata name,
        uint256 version
    ) external payable;
}
