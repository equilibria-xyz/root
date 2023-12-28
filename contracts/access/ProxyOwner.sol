// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

/**
 * @title ProxyOwner
 * @notice ProxyAdmin with 2-step ownership transfer
 * @dev Adds 2-step ownership transfer to the OpenZeppelin ProxyAdmin contract, both for the owner of the ProxyAdmin
 *      and to the proxy ownership transfer.
 */
contract ProxyOwner is ProxyAdmin, Ownable2Step {
    error ProxyOwnerNotPendingAdminError();

    /// @dev Mapping of the pending admin for each proxy
    mapping(TransparentUpgradeableProxy => address) public pendingAdmins;

    /// @dev Only allows calls from the pending admin of `proxy`
    modifier onlyPendingOwner(TransparentUpgradeableProxy proxy) {
        if(pendingAdmins[proxy] != msg.sender) revert ProxyOwnerNotPendingAdminError();
        _;
    }
    
    /// @notice Sets the pending admin for `proxy` to `newAdmin`
    /// @param proxy The proxy to change the pending admin for
    /// @param newAdmin The address of the new pending admin
    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public override onlyOwner {
        pendingAdmins[proxy] = newAdmin;
    }

    /// @notice Processes the admin change for `proxy`
    /// @dev Callback used by the new proxy owner
    /// @param proxy The proxy to accept the pending admin for
    function acceptProxyAdminCallback(TransparentUpgradeableProxy proxy) external onlyPendingOwner(proxy) {
        proxy.changeAdmin(msg.sender);
        delete pendingAdmins[proxy];
    }

    /// @notice Accepts ownership of `proxy`
    /// @param previousOwner The previous owner of the proxy
    /// @param proxy The proxy to accept ownership of
    function acceptProxyAdmin(ProxyOwner previousOwner, TransparentUpgradeableProxy proxy) external onlyOwner {
        previousOwner.acceptProxyAdminCallback(proxy);
    }

    function transferOwnership(address newOwner) public override(Ownable, Ownable2Step) {
        super.transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal override(Ownable, Ownable2Step) {
        super._transferOwnership(newOwner);
    }
}
