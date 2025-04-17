// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { Proxy } from "./Proxy.sol";

/// @title ProxyPauseTarget
/// @dev Stub contract Proxy sets as the implementation whenever the proxied contract is paused.
///      This eliminates the need for a storage read to check paused state on each interaction.
contract ProxyPauseTarget {
    fallback() external payable virtual {
        revert Proxy.ProxyPausedError();
    }
}
