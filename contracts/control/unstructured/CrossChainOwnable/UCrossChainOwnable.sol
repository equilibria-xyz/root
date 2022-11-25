// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/CrossChainEnabled.sol";
import "../UOwnable.sol";
import "../../../storage/UStorage.sol";

/**
 * @title UCrossChainOwnable
 * @notice Library to manage the cross-chain ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract UCrossChainOwnable is UOwnable, CrossChainEnabled {
    BoolStorage private constant _crossChainRestricted = BoolStorage.wrap(keccak256("equilibria.root.UCrossChainOwnable.crossChainRestricted"));
    function crossChainRestricted() public view returns (bool) { return _crossChainRestricted.read(); }

    function acceptOwner() public override {
        _crossChainRestricted.store(true);
        super.acceptOwner();
    }

    function _sender() internal view override returns (address) {
        if (crossChainRestricted()) return _crossChainSender();
        return msg.sender;
    }
}
