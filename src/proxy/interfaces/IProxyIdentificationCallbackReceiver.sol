// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @dev Used by ProxyAdmin to identify the proxy.  This is necessary because the proxy
/// cannot return values itself.
interface IProxyIdentificationCallbackReceiver {
    /// @dev Only the requested proxy is allowed to invoke the onIdentify callback
    error ProxyNotIdentifier();

    /// @dev Called when the proxy identifies itself
    function onIdentify(string memory name, uint256 version) external;
}
