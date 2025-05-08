// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IOwnable } from "../../attribute/interfaces/IOwnable.sol";
import { IPausable } from "../../attribute/interfaces/IPausable.sol";
import { IImplementation } from "./IImplementation.sol";
import { IMutableTransparent } from "./IMutable.sol";

/// @dev The publicly available interface of the Mutator contract.
interface IMutator is IOwnable, IPausable {
    function mutables() external view returns (address[] memory);
    function create(string calldata name, IImplementation implementation, bytes calldata data) external returns (IMutableTransparent newMutable);
    function upgrade(string calldata name, IImplementation implementation, bytes memory data) external payable;
}
