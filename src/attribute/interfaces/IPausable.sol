// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IOwnable } from "./IOwnable.sol";
import { IAttribute } from "../../attribute/interfaces/IAttribute.sol";

interface IPausable is IAttribute, IOwnable {
    event PauserUpdated(address indexed newPauser);
    event Paused();
    event Unpaused();

    // sig: 0x78cefddd
    /// @custom:error Contract is paused
    error PausablePausedError();
    // sig: 0xf7987a92
    /// @custom:error Caller is not the pauser
    error PausableNotPauserError(address sender);

    function pauser() external view returns (address);
    function paused() external view returns (bool);
    function updatePauser(address newPauser) external;
    function pause() external;
    function unpause() external;
}
