// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Bank} from "../src/Bank.sol";
import {Token} from "../src/Token.sol";
import {Test} from "forge-std/Test.sol";

contract BaseSetup is Test {
    string seed = "test test test test test test test test test test test junk";
    bytes32 internal nextUser = keccak256(abi.encodePacked(seed));

    address[] _users;
    address controller;
    address alice;
    address bob;

    Bank bank;
    Token token;

    function setUp() public virtual {
        _users = createUsers(3);

        controller = _users[0];
        bob = _users[1];
        alice = _users[2];

        vm.label(controller, "CONTROLLER");
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");


        vm.prank(controller);
        token = new Token();
        vm.prank(controller);
        bank = new Bank(address(token));
    }

    function getNextUserAddress() private returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }


    ///
    function createUsers(uint256 userNum) private returns (address payable[] memory) {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = getNextUserAddress();
            vm.deal(user, 10000 ether);
            users[i] = user;
        }
        return users;
    }
}
