// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet, Action} from "../src/diamond/interfaces/Types.sol";
import {Diamond} from "../src/diamond/Diamond.sol";
import {Bank} from "../src/facet/Bank.sol";
import {Token} from "../src/facet/Token.sol";
import {Test} from "forge-std/Test.sol";

contract BaseSetup is Test {
    address[] _users;
    address controller;
    address alice;
    address bob;
    address eve;
    address zero;

    function setUp() public virtual {
        _users = createUsers(4);

        controller = _users[0];
        alice = _users[1];
        bob = _users[2];
        eve = _users[3];
        zero = address(0x0);

        vm.label(controller, "CONTROLLER");
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");
        vm.label(eve, "EVE");
        vm.label(zero, "ZERO");
    }
}
