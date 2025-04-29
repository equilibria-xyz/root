// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { Implementation } from "./Implementation.sol";
import { IMutable } from "./interfaces/IMutable.sol";

// TODO
abstract contract Mutable is IMutable, Implementation {
    /// @notice The slot of the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.Initializable.initializing");

    /// @notice The slot of the initialized version
    bytes32 private constant VERSION_SLOT = keccak256("equilibria.root.Initializable.version");

    // TODO
    function initialize(bytes calldata data) external {
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = true;

        uint256 version = __initialize(data);
        if (version == 0) revert MutableZeroVersionError();
        if (StorageSlot.getUint256Slot(VERSION_SLOT).value >= version) revert MutableAlreadyInitializedError(version);

        StorageSlot.getUint256Slot(VERSION_SLOT).value = version;
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = false;

        emit Initialized(version);
    }
}
