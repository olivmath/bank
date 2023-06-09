// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseBankTest} from "./BaseBank.t.sol";
import {Token} from "../../src/facet/Token.sol";
import {Bank} from "../../src/facet/Bank.sol";

contract PayEmployees is BaseBankTest {
    function setUp() public virtual override {
        BaseBankTest.setUp();

        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, aliceBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, bobBudge));
        address(diamond).call(abi.encodeWithSelector(createEmployee, eve, eveBudge));

        token.transfer(address(diamond), 100000 * 10e18);
        vm.stopPrank();
    }

    function testAddAndRemoveEmployees() public {
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getTotalEmployeeCost));
        uint256 totalCostBefore = abi.decode(data, (uint256));

        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(deleteEmployee, alice));
        address(diamond).call(abi.encodeWithSelector(deleteEmployee, bob));
        address(diamond).call(abi.encodeWithSelector(deleteEmployee, eve));
        vm.stopPrank();

        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(getTotalEmployeeCost));
        uint256 totalCostAfter = abi.decode(data2, (uint256));

        assertEq(totalCostBefore, aliceBudge + bobBudge + eveBudge, "Incorrect total cost before deletion.");
        assertEq(totalCostAfter, 0, "Incorrect total cost after deletion.");
    }

    function testPayEmployees() public {
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getBalance));
        uint256 balanceBefore = abi.decode(data, (uint256));

        vm.roll(locktime);

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));
        uint256 balanceAfter = token.balanceOf(address(diamond));

        assertEq(token.balanceOf(alice), aliceBudge, "Alicee did not receive correct budge.");
        assertEq(token.balanceOf(bob), bobBudge, "Bob did not receive correct budge.");
        assertEq(token.balanceOf(eve), eveBudge, "Eve did not receive correct budge.");
        assertEq(
            balanceAfter,
            balanceBefore - aliceBudge - bobBudge - eveBudge,
            "Bank balance did not decrease by correct amount."
        );
    }

    function testAddFunds() public {
        uint256 amountToAdd = 100 * 10e18;
        uint256 balanceBefore = token.balanceOf(address(diamond));

        vm.prank(controller);
        token.transfer(address(diamond), amountToAdd);
        uint256 balanceAfter = token.balanceOf(address(diamond));

        assertEq(balanceAfter, balanceBefore + amountToAdd, "Bank balance did not increase by correct amount.");
    }

    function testEmployeeCost() public {
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getTotalEmployeeCost));
        uint256 totalCost = abi.decode(data, (uint256));
        assertEq(totalCost, aliceBudge + bobBudge + eveBudge, "Employees cust should be 6000");
    }

    function testPayBobEmployee() public {
        uint256 oldBalance = token.balanceOf(bob);

        vm.roll(locktime);

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));

        uint256 newBalance = token.balanceOf(bob);
        assertEq(newBalance, oldBalance + bobBudge, "Employee should receive the payment");
    }

    function testRollBlocks() public {
        address newEmployee = address(0x1234);
        uint256 employeeBudge = 10 * 10e18;
        vm.roll(locktime);

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, newEmployee, employeeBudge));
        uint256 oldBalance = token.balanceOf(newEmployee);

        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getAllEmployees));
        address[] memory employeeList = abi.decode(data, (address[]));
        assertEq(employeeList.length, 4);

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));

        uint256 newBalance = token.balanceOf(newEmployee);
        assertEq(newBalance, oldBalance, "Employee should not receive the payment");

        vm.roll(locktime * 2);

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));

        newBalance = token.balanceOf(newEmployee);
        assertEq(newBalance, oldBalance + employeeBudge, "Employee should receive the payment");
        assertEq(token.balanceOf(alice), aliceBudge * 2, "Alice should receive the payment");
        assertEq(token.balanceOf(eve), eveBudge * 2, "Eve should receive the payment");
        assertEq(token.balanceOf(bob), bobBudge * 2, "Bob should receive the payment");
    }

    function testPayAllEmployeesWithInsufficientBalance() public {
        // adicionar novoEmployee com budge 99000
        address newEmployee = address(0x1234);
        uint256 newEmployeeBudge = 99000 * 10e18;

        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, newEmployee, newEmployeeBudge));

        // roll blocks
        vm.roll(locktime);

        // chamar pagamento
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));

        // verificar se novoEmployee recebeu uma parte do apgamento
        uint256 lastBalance = token.balanceOf(newEmployee);
        assertEq(lastBalance, 90000 * 10e18, "New Employee should receive 90000 of payment");

        // verificar se novoEmployee tem bonus
        (, bytes memory data) = address(diamond).call(abi.encodeWithSelector(getEmployee, newEmployee));
        (,, uint256 bonus) = abi.decode(data, (address, uint256, uint256));
        assertEq(bonus, 9000 * 10e18, "New Employee should have 9000 of bonus");

        // adicionar saldo no contrato
        vm.prank(controller);
        token.transfer(address(diamond), 118000 * 10e18);

        // chamar pagamento
        vm.prank(controller);
        address(diamond).call(abi.encodeWithSelector(payAllEmployees));

        // verificar se novoEmployee recebeu  pagamento + bonus
        assertEq(
            token.balanceOf(newEmployee),
            9000 * 10e18 + newEmployeeBudge + lastBalance,
            "New Employee should receive 99000 + 9000 of payment"
        );

        // verificar se novoEmployee bonus == 0
        (, data) = address(diamond).call(abi.encodeWithSelector(getEmployee, newEmployee));
        (,, bonus) = abi.decode(data, (address, uint256, uint256));
        assertEq(bonus, 0, "New Employee should have 0 of bonus");
    }
}
