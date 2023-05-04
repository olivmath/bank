// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Bank} from "../src/facet/Bank.sol";
import {Token} from "../src/facet/Token.sol";
import {Test} from "forge-std/Test.sol";
import {BaseSetup} from "./BaseSetup.sol";

contract BankTest is BaseSetup {
    function setUp() public virtual override {
        // ----------------
        // BANK CONTRACT
        // ----------------
        // 0x520a19c0  =>  createEmployee(address,uint256)
        // 0x5e91d8ec  =>  updateEmployee(address,uint256)
        // 0x6e7c4ab1  =>  deleteEmployee(address)
        // 0xe3366fed  =>  getAllEmployees() -> address[] memory
        // 0x32648e09  =>  getEmployee(address) -> (address, uint256)

        BaseSetup.setUp();
    }

    function testCreateEmployee() public {
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, bob, 5000));
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(0x32648e09, bob));
        (address employee, uint256 budge) = abi.decode(data, (address, uint256));

        assertEq(employee, bob, "Employee address should be equal to bob's address.");
        assertEq(budge, 5000, "Employee budge should be 5000.");
    }

    function testUpdateEmployee() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, alice, 2000));
        address(diamond).call(abi.encodeWithSelector(0x5e91d8ec, alice, 3000));
        vm.stopPrank();
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(0x32648e09, alice));
        (, uint256 budge) = abi.decode(data, (address, uint256));

        assertEq(budge, 3000, "Employee budge should be updated to 3000.");
    }

    function testFailUpdateNonexistentEmployee() public {
        vm.prank(controller);
        (bool success, bytes memory data) =
            address(diamond).call(abi.encodeWithSelector(0x5e91d8ec, address(123), 3000));
        if (!success) {
            revert(abi.decode(data, (string)));
        }
    }

    function testDeleteEmployee() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, alice, 1000));
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, bob, 2000));
        address(diamond).call(abi.encodeWithSelector(0x6e7c4ab1, alice));
        vm.stopPrank();

        (, bytes memory data1) = address(diamond).call(abi.encodeWithSelector(0x32648e09, alice));
        (address employee,) = abi.decode(data1, (address, uint256));

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(0xe3366fed));
        address[] memory employees = abi.decode(data2, (address[]));

        assertEq(employees.length, 1, "Employee budge should be updated to 3000.");
        assertTrue(employee == address(0), "Employee should be deleted.");
    }

    function testGetAllEmployees() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, alice, 1000));
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, bob, 2000));
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, address(0x3333), 3000));
        vm.stopPrank();

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(0xe3366fed));
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
            employees[0] == address(0x3333) || employees[1] == address(0x3333) || employees[2] == address(0x3333),
            "0x3333 should be in the list of employees."
        );
    }

    function testCreateDuplicateEmployee() public {
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(0x520a19c0, alice, 1000));

        vm.prank(controller);
        (bool success,) = address(diamond).call(abi.encodeWithSelector(0x520a19c0, alice, 1000));
        assertFalse(success, "Creating duplicate employee should fail.");

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(0xe3366fed));
        address[] memory employees = abi.decode(data2, (address[]));
        assertTrue(employees.length == 1, "There should be only one employee.");
    }
}
