// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./IInitializable.sol";

interface IReentrancyGuard is IInitializable {
    // sig: 0x8becf012
    /// @custom:error Reentrant call
    error ReentrancyGuardReentrantCallError();
}
