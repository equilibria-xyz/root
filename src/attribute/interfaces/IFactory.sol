// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IBeacon } from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

import { IOwnable } from "src/attribute/interfaces/IOwnable.sol";
import { IPausable } from "src/attribute/interfaces/IPausable.sol";
import { IInstance } from "src/attribute/interfaces/IInstance.sol";

interface IFactory is IBeacon, IOwnable, IPausable {
    event InstanceRegistered(IInstance indexed instance);

    // sig: 0x9dd1d227
    /// @custom:error Contract is not an instance of the factory
    error FactoryNotInstanceError();

    function instances(IInstance instance) external view returns (bool);
}
