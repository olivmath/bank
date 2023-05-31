// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error WithMultipleArgs(string msg, uint256 x, int256 y, bool truth);
error WithStringArgs(string msg);
error WithBoolArgs(bool truth);
error WithUintArgs(uint256 x);
error WithoutArgs();

contract FrontErrors {
    function withMultipleArgs() external pure {
        revert WithMultipleArgs("Helo", 777, -777, true);
    }

    function withStringArgs() external pure {
        revert WithStringArgs("Hello");
    }

    function withBoolArgs() external pure {
        revert WithBoolArgs(true);
    }

    function withUintArgs() external pure {
        revert WithUintArgs(777);
    }

    function withoutArgs() external pure {
        revert WithoutArgs();
    }
    function withRequire() external pure {
        require(false, "Erro by require");
    }
}
