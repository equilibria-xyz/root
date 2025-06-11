// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IAttribute } from "./IAttribute.sol";
import { IOwnable } from "./IOwnable.sol";

interface IExecutable is IAttribute, IOwnable {
    function execute(address target, bytes calldata data) external payable returns (bytes memory);
}
