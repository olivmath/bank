// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseBankTest} from "./BaseBank.t.sol";
import {Token} from "../../src/facet/Token.sol";
import {Bank} from "../../src/facet/Bank.sol";

contract PayEmployees is BaseBankTest {
    function setUp() public virtual override {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, bobBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, eve, eveBudge));
        vm.stopPrank();
    }

    function testAddAndRemoveEmployees() public {
        uint256 totalCostBefore = bank.totalCost();
        bank.deleteEmployee(employee1);
        bank.deleteEmployee(employee2);
        bank.deleteEmployee(employee3);
        uint256 totalCostAfter = bank.totalCost();

        assertEq(
            totalCostBefore, employee1Budge + employee2Budge + employee3Budge, "Incorrect total cost before deletion."
        );
        assertEq(totalCostAfter, 0, "Incorrect total cost after deletion.");
    }

    function testPayEmployees() public {
        uint256 balanceBefore = token.balanceOf(address(bank));
        bank.payEmployees();
        uint256 balanceAfter = token.balanceOf(address(bank));

        assertEq(token.balanceOf(employee1), employee1Budge, "Employee 1 did not receive correct budge.");
        assertEq(token.balanceOf(employee2), employee2Budge, "Employee 2 did not receive correct budge.");
        assertEq(token.balanceOf(employee3), employee3Budge, "Employee 3 did not receive correct budge.");
        assertEq(
            balanceAfter,
            balanceBefore - employee1Budge - employee2Budge - employee3Budge,
            "Bank balance did not decrease by correct amount."
        );
    }

    function testAddFunds() public {
        uint256 amountToAdd = 100;
        uint256 balanceBefore = token.balanceOf(address(bank));
        token.transfer(address(bank), amountToAdd);
        uint256 balanceAfter = token.balanceOf(address(bank));

        assertEq(balanceAfter, balanceBefore + amountToAdd, "Bank balance did not increase by correct amount.");
    }

    function addEmployee() public {
        bank.createEmployee(address(this), 10);
        employees.push(address(this));
    }

    function testEmployeeCost() public {
        addEmployee();
        addEmployee();
        uint256 cost = bank.getEmployeeCost();
        Assert.equal(cost, 20, "Employee cost should be 20");
        bank.deleteEmployee(address(this));
        cost = bank.getEmployeeCost();
        Assert.equal(cost, 10, "Employee cost should be 10");
    }

    function testPayEmployees() public {
        token.transfer(address(bank), 50);
        addEmployee();
        uint256 oldBalance = token.balanceOf(address(employees[0]));
        bank.payEmployees();
        uint256 newBalance = token.balanceOf(address(employees[0]));
        Assert.greaterThan(newBalance, oldBalance, "Employee should receive the payment");
    }

    function testRollBlocks() public {
        addEmployee();
        uint256 oldBalance = token.balanceOf(address(employees[1]));
        uint256 startBlock = block.number;
        while (block.number < startBlock + locktime) {
            block.timestamp += 1 days;
        }
        bank.payEmployees();
        uint256 newBalance = token.balanceOf(address(employees[1]));
        Assert.equal(newBalance, oldBalance, "Employee should not receive the payment");
    }

    function testPayNonexistentEmployee() public {
        bool success = address(bank).call(abi.encodeWithSignature("payEmployee(address)", address(this)));
        Assert.ok(!success, "Should not be possible to pay nonexistent employee");
    }

    function testPayCompletedLocktimeEmployee() public {
        addEmployee();
        bank.payEmployees();
        uint256 startBlock = block.number;
        while (block.number < startBlock + locktime) {
            block.timestamp += 1 days;
        }
        uint256 oldBalance = token.balanceOf(address(employees[2]));
        bank.payEmployees();
        uint256 newBalance = token.balanceOf(address(employees[2]));
        Assert.greaterThan(newBalance, oldBalance, "Employee should receive the payment");
    }

    function testPayEmployeesWithInsufficientBalance() public {
        token.transfer(address(bank), 5);
        bool success = address(bank).call(abi.encodeWithSignature("payEmployees()"));
        Assert.ok(!success, "Should not be possible to pay employees with insufficient balance");
    }

    function testEmployeeCostAfterPayment() public {
        addEmployee();
        uint256 costBefore = bank.getEmployeeCost();
        bank.payEmployees();
        uint256 costAfter = bank.getEmployeeCost();
        Assert.equal(costBefore, costAfter, "Employee cost should not change after payment");
    }
}
