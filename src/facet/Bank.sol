// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Token} from "./Token.sol";
import {DiamondStorageLib} from "../diamont/Lib.sol";

/**
 * @title Bank
 * @notice A contract to manage employee budgets using the Diamond Storage Library
 */
contract Bank {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    /**
     * @dev Initialize the bank contract with a token address
     * @param _token The address of the token to be used
     */
    constructor(address _token) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        ds.token = _token;
    }

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
        ds.employees[_employee] = DiamondStorageLib.Employee(_employee, _budge, employeeLocktime);
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
    function getEmployee(address employee) public view returns (address, uint256) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        DiamondStorageLib.Employee memory emp = ds.employees[employee];
        return (emp.employee, emp.budge);
    }

    /**
     * @dev Get the token balance of the bank
     * @return balance The token balance of the bank
     */
    function getBalance() public view returns (uint256 balance) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        Token token = Token(ds.token);
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
            totalCost += emp.budge;
        }
    }

    /**
     * @dev Pay all employees their respective budgets
     */
    function payAllEmployees() public {
        onlyController();
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        Token token = Token(ds.token);

        for (uint256 i = 0; i < ds.employeeList.length; i++) {
            address employeeAddress = ds.employeeList[i];
            DiamondStorageLib.Employee storage employee = ds.employees[employeeAddress];

            require(block.number >= employee.locktime, "Employee's locktime has not passed yet.");

            require(token.transfer(employeeAddress, employee.budge), "Transfer failed.");

            employee.locktime = block.number + DiamondStorageLib.LOCKTIME_IN_BLOCKS;
        }
    }
}
