// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Bank} from "../src/Bank.sol";
import {Token} from "../src/Token.sol";
import {Test} from "forge-std/Test.sol";
import {BaseSetup} from "./BaseSetup.sol";

contract BankTest is BaseSetup {
    
    function testCreateEmployee() public {
        vm.prank(controller);
        bank.createEmployee(bob, 5000);
        (address employee, uint256 budge) = bank.getEmployee(bob);
        
        assertEq(employee, bob, "Employee address should be equal to bob's address.");
        assertEq(budge, 5000, "Employee budge should be 5000.");
    }

    function testUpdateEmployee() public {
        vm.startPrank(controller);
        bank.createEmployee(alice, 2000);
        bank.updateEmployee(alice, 3000);
        vm.stopPrank();
        (, uint256 budge) = bank.getEmployee(alice);

        assertEq(budge, 3000, "Employee budge should be updated to 3000.");
    }

    function testFailUpdateNonexistentEmployee() public {
        vm.prank(controller);
        bank.updateEmployee(alice, 3000);
    }

    function testDeleteEmployee() public {
        vm.startPrank(controller);
        bank.createEmployee(alice, 1000);
        bank.deleteEmployee(alice);
        vm.stopPrank();
        (address employee,) = bank.getEmployee(alice);
        assertTrue(employee == address(0), "Employee should be deleted.");
    }
}