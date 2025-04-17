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

// This was an attempt to use staticcall to access views on the proxied contract.
// It did not revert, but debugger shows empty returndata buffer.
// Could try to incorporate this into the ProxyPauseTarget contract to make it a
// second-layer "read-only" proxy.
/*function _staticCall(address implementation) internal virtual {
    assembly {
        calldatacopy(0, 0, calldatasize())
        let result := staticcall(gas(), implementation, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())

        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(1, returndatasize()) }
    }
}*/
