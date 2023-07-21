// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./IInitializable.sol";

interface IReentrancyGuard is IInitializable {
    error UReentrancyGuardReentrantCallError();
}
