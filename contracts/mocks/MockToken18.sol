// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../token/types/Token18.sol";

contract MockToken18 {
    function zero() external pure returns (Token18) {
        return Token18Lib.ZERO;
    }

    function isZero(Token18 token) external pure returns (bool) {
        return Token18Lib.isZero(token);
    }

    function eq(Token18 a, Token18 b) external pure returns (bool) {
        return Token18Lib.eq(a, b);
    }

    function approve(Token18 self, address grantee) external {
        Token18Lib.approve(self, grantee);
    }

    function approve(Token18 self, address grantee, UFixed18 amount) external {
        Token18Lib.approve(self, grantee, amount);
    }

    function push(Token18 self, address recipient) external {
        Token18Lib.push(self, recipient);
    }

    function push(Token18 self, address recipient, UFixed18 amount) external {
        Token18Lib.push(self, recipient, amount);
    }

    function pull(Token18 self, address benefactor, UFixed18 amount) external {
        Token18Lib.pull(self, benefactor, amount);
    }

    function pullTo(Token18 self, address benefactor, address recipient, UFixed18 amount) external {
        Token18Lib.pullTo(self, benefactor, recipient, amount);
    }

    function name(Token18 self) external view returns (string memory) {
        return Token18Lib.name(self);
    }

    function symbol(Token18 self) external view returns (string memory) {
        return Token18Lib.symbol(self);
    }

    function balanceOf(Token18 self) external view returns (UFixed18) {
        return Token18Lib.balanceOf(self);
    }

    function balanceOf(Token18 self, address account) external view returns (UFixed18) {
        return Token18Lib.balanceOf(self, account);
    }

    function read(Token18Storage slot) external view returns (Token18) {
        return slot.read();
    }

    function store(Token18Storage slot, Token18 value) external {
        slot.store(value);
    }
}