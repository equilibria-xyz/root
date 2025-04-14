// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IFactory } from "src/attribute/interfaces/IFactory.sol";
import { IInitializable } from "src/attribute/interfaces/IInitializable.sol";

interface IInstance is IInitializable {
    // sig: 0x4d193d1f
    /// @custom:error Caller is not the owner
    error InstanceNotOwnerError(address sender);
    // sig: 0x864ec51e
    /// @custom:error Caller is not the factory
    error InstanceNotFactoryError(address sender);
    // sig: 0x4b94d2bb
    /// @custom:error Contract is paused
    error InstancePausedError();

    function factory() external view returns (IFactory);
}
