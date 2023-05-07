// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DiamondStorageLib} from "../diamont/Lib.sol";
import {ERC20} from "../facet/Token.sol";
import {Token} from "./Token.sol";

/**
 * @title Bank
 * @notice A contract to manage employee budgets using the Diamond Storage Library
 */
contract Bank {
    ERC20 token;

    event Paid(address employee, uint256 budge);

    event Bonus(address employee, uint256 bonus);

    using DiamondStorageLib for DiamondStorageLib.Storage;

    /**
     * @dev Initialize the bank contract with a token address
     */
    constructor() {}

    function onlyController() internal view {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.controller == msg.sender, "NOT_AUTHORIZED");
    }

    /**
     * @dev Create a new employee
     * @param _employee address of the new employee
     * @param _budge budge amount for the employee
     */
    function createEmployee(address _employee, uint256 _budge) public {
        onlyController();
        require(_employee != address(0x0), "ZERO_ADDRESS");
        require(_budge > 1 * 10e18, "LOW_BUDGE");
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee == address(0), "Employee already exists.");
        uint256 employeeLocktime = block.number + DiamondStorageLib.LOCKTIME_IN_BLOCKS;
        ds.employees[_employee] = DiamondStorageLib.Employee(_employee, _budge, employeeLocktime, 0);
        ds.employeeList.push(_employee);
    }

    /**
     * @dev Update an employee's information
     * @param _employee address of the employee to be updated
     * @param _budge new budge amount for the employee
     */
    function updateEmployee(address _employee, uint256 _budge) public {
        onlyController();
        require(_budge > 1 * 10e18, "LOW_BUDGE");
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee != address(0), "Employee does not exist.");
        ds.employees[_employee].budge = _budge;
    }

    /**
     * @dev Delete an employee
     * @param _employee address of the employee to be deleted
     */
    function deleteEmployee(address _employee) public {
        onlyController();
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee != address(0), "Employee does not exist.");
        delete ds.employees[_employee];

        // Remove employee from employeeList
        for (uint256 i = 0; i < ds.employeeList.length; i++) {
            if (ds.employeeList[i] == _employee) {
                ds.employeeList[i] = ds.employeeList[ds.employeeList.length - 1];
                ds.employeeList.pop();
                break;
            }
        }
    }

    /**
     * @dev Get the list of all employees
     * @return employees array containing addresses of all employees
     */
    function getAllEmployees() public view returns (address[] memory employees) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        employees = ds.employeeList;
    }

    /**
     * @dev Get a employee
     * @return address and budge of a employee
     */
    function getEmployee(address employee) public view returns (address, uint256, uint256) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        DiamondStorageLib.Employee memory emp = ds.employees[employee];
        return (emp.employee, emp.budge, emp.bonus);
    }

    /**
     * @dev Get the token balance of the bank
     * @return balance The token balance of the bank
     */
    function getBalance() public returns (uint256 balance) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        token = Token(ds.token);
        balance = token.balanceOf(address(this));
    }

    /**
     * @dev Get the total cost of all employees
     * @return totalCost of all employees
     */
    function getTotalEmployeeCost() public view returns (uint256 totalCost) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        for (uint256 i = 0; i < ds.employeeList.length; i++) {
            address employeeAddress = ds.employeeList[i];
            DiamondStorageLib.Employee memory emp = ds.employees[employeeAddress];
            totalCost += emp.budge + emp.bonus;
        }
    }

    /**
     * @dev Pay all employees their respective budgets
     */
    function payAllEmployees() public {
        onlyController();
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        token = Token(ds.token);
        DiamondStorageLib.Employee memory emp;
        uint256 contractBalance = token.balanceOf(address(this));

        for (uint256 i = 0; i < ds.employeeList.length; i++) {
            address employee = ds.employeeList[i];
            emp = ds.employees[employee];
            uint256 total = emp.budge + emp.bonus;

            if (emp.locktime > block.number) {
                continue;
            } else if (total <= contractBalance) {
                token.transfer(emp.employee, total);
                unchecked {
                    contractBalance -= emp.budge;
                }
            } else if (contractBalance > 0) {
                emp.bonus += emp.budge - contractBalance;
                token.transfer(emp.employee, contractBalance);
                contractBalance = 0;
            } else {
                emp.bonus += emp.budge - contractBalance;
            }
        }
    }
}
