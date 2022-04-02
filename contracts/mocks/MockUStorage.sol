// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../storage/UStorage.sol";

contract MockUStorage is UStorage {
    function readBool(bytes32 slot) external view returns (bool) {
        return _readBool(slot);
    }

    function write(bytes32 slot, bool value) external {
        _write(slot, value);
    }

    function readUint256(bytes32 slot) external view returns (uint256) {
        return _readUint256(slot);
    }

    function write(bytes32 slot, uint256 value) external {
        _write(slot, value);
    }

    function readInt256(bytes32 slot) external view returns (int256) {
        return _readInt256(slot);
    }

    function write(bytes32 slot, int256 value) external {
        _write(slot, value);
    }

    function readAddress(bytes32 slot) external view returns (address) {
        return _readAddress(slot);
    }

    function write(bytes32 slot, address value) external {
        _write(slot, value);
    }

    function readBytes32(bytes32 slot) external view returns (bytes32) {
        return _readBytes32(slot);
    }

    function write(bytes32 slot, bytes32 value) external {
        _write(slot, value);
    }

    function readUFixed18(bytes32 slot) external view returns (UFixed18) {
        return _readUFixed18(slot);
    }

    function writeUFixed18(bytes32 slot, UFixed18 value) external {
        _write(slot, value);
    }

    function readFixed18(bytes32 slot) external view returns (Fixed18) {
        return _readFixed18(slot);
    }

    function writeFixed18(bytes32 slot, Fixed18 value) external {
        _write(slot, value);
    }
}
