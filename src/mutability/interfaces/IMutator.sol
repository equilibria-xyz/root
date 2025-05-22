// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IOwnable } from "../../attribute/interfaces/IOwnable.sol";
import { IImplementation } from "./IImplementation.sol";
import { IMutableTransparent } from "./IMutable.sol";

/// @dev The publicly available interface of the Mutator contract.
interface IMutator is IOwnable {
    /// @dev Emitted when the address allowed to pause and unpause is updated
    event PauserUpdated(address indexed newPauser);

    // sig: 0xf125c967
    /// @custom:error Mutable contract was not deployed thus cannot be upgraded
    error MutatorInvalidMutable();
    // sig: 0xf6ebbed0
    /// @custom:error Caller is not the pauser
    error MutatorNotPauserError(address sender);

    function mutables() external view returns (address[] memory);
    function create(IImplementation implementation, bytes calldata data) external returns (IMutableTransparent newMutable);
    function upgrade( IImplementation implementation, bytes memory data) external payable;
}
