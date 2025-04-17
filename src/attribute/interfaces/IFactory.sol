// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IBeacon } from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

import { IOwnable } from "./IOwnable.sol";
import { IPausable } from "./IPausable.sol";
import { IInstance } from "./IInstance.sol";

interface IFactory is IBeacon, IOwnable, IPausable {
    event InstanceRegistered(IInstance indexed instance);

    // sig: 0x9dd1d227
    /// @custom:error Contract is not an instance of the factory
    error FactoryNotInstanceError();

    function instances(IInstance instance) external view returns (bool);
}
