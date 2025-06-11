// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import { IAttribute } from "./IAttribute.sol";
import { IOwnable } from "./IOwnable.sol";

interface IDelegatable is IAttribute, IOwnable {
    function delegate(IVotes token, address delegatee) external;
}
