// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseBankTest} from "./BaseBank.t.sol";

contract EmployeeManagerTest is BaseBankTest {
    function setUp() public virtual override {
        BaseBankTest.setUp();
    }

    function testCreateEmployee() public {
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, bobBudge * 10e18));
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getEmployee, bob));
        (address employee, uint256 budge) = abi.decode(data, (address, uint256));

        assertEq(employee, bob, "Employee address should be equal to bob's address.");
        assertEq(budge, bobBudge * 10e18, "Employee budge should be 5000.");
    }

    function testUpdateEmployee() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge * 10e18));
        address(diamond).call(abi.encodeWithSelector(updateEmployee, alice, 3000 * 10e18));
        vm.stopPrank();
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getEmployee, alice));
        (, uint256 budge) = abi.decode(data, (address, uint256));

        assertEq(budge, 3000 * 10e18, "Employee budge should be updated to 3000.");
    }

    function testFailUpdateNonexistentEmployee() public {
        vm.prank(controller);
        (bool success, bytes memory data) = address(diamond).call(abi.encodeWithSelector(updateEmployee, bob, bobBudge));
        if (!success) {
            revert(abi.decode(data, (string)));
        }
    }

    function testDeleteEmployee() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, bobBudge));
        address(diamond).call(abi.encodeWithSelector(deleteEmployee, alice));
        vm.stopPrank();

        (, bytes memory data1) = address(diamond).call(abi.encodeWithSelector(getEmployee, alice));
        (address employee,) = abi.decode(data1, (address, uint256));

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(getAllEmployees));
        address[] memory employees = abi.decode(data2, (address[]));

        assertEq(employees.length, 1, "Should have just 1 employee");
        assertTrue(employee == zero, "Employee should be deleted.");
    }

    function testGetAllEmployees() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, bobBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, eve, eveBudge));
        vm.stopPrank();

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(getAllEmployees));
        address[] memory employees = abi.decode(data2, (address[]));

        assertTrue(employees.length == 3, "There should be 3 employees.");
        assertTrue(
            employees[0] == alice || employees[1] == alice || employees[2] == alice,
            "Alice should be in the list of employees."
        );
        assertTrue(
            employees[0] == alice || employees[1] == bob || employees[2] == bob,
            "Bob should be in the list of employees."
        );
        assertTrue(
            employees[0] == eve || employees[1] == eve || employees[2] == eve,
            "0x3333 should be in the list of employees."
        );
    }

    function testCreateDuplicateEmployee() public {
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));

        vm.prank(controller);
        (bool success,) = address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));
        assertFalse(success, "Creating duplicate employee should fail.");

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(getAllEmployees));
        address[] memory employees = abi.decode(data2, (address[]));
        assertTrue(employees.length == 1, "There should be only one employee.");
    }
}
