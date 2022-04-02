// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.13;

import "./number/types/UFixed18.sol";

contract UStorage {
    function _readBool(bytes32 slot) internal view returns (bool result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, bool value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readUint256(bytes32 slot) internal view returns (uint256 result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, uint256 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readInt256(bytes32 slot) internal view returns (int256 result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, int256 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readAddress(bytes32 slot) internal view returns (address result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, address value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readBytes32(bytes32 slot) internal view returns (bytes32 result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, bytes32 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readUFixed18(bytes32 slot) internal view returns (UFixed18 result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, UFixed18 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    function _readFixed18(bytes32 slot) internal view returns (Fixed18 result) {
        assembly {
            result := sload(slot)
        }
    }

    function _write(bytes32 slot, Fixed18 value) internal {
        assembly {
            sstore(slot, value)
        }
    }
}
