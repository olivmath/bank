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
    /**
     * @dev Emitted when an employee is paid their budge
     * @param employee Address of the employee being paid
     * @param budge Amount of budge paid to the employee
     */

    event Paid(address indexed employee, uint256 budge);

    /**
     * @dev Emitted when there's not enough balance to pay the full budge, and the remaining amount is added as a bonus
     * @param employee Address of the employee receiving the bonus
     * @param bonus Amount of bonus added to the employee's balance
     */
    event Bonus(address indexed employee, uint256 bonus);

    using DiamondStorageLib for DiamondStorageLib.Storage;

    /**
     * @dev Initialize the bank contract
     */
    constructor() {}

    /**
     * @notice Modifier to restrict function access to controller only
     */
    function onlyController() internal view {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.controller == msg.sender, "NOT_AUTHORIZED");
    }

    /**
     * @notice Creates a new employee with the provided budge
     * @dev Create a new employee with `locktime` from the current block
     * @param _employee Address of the new employee
     * @param _budge Budge amount for the employee
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
     * @notice Updates an employee's budge
     * @dev Update an employee's information
     * @param _employee Address of the employee to be updated
     * @param _budge New budge amount for the employee
     */
    function updateEmployee(address _employee, uint256 _budge) public {
        onlyController();
        require(_budge > 1 * 10e18, "LOW_BUDGE");
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee != address(0), "Employee does not exist.");
        ds.employees[_employee].budge = _budge;
    }

    /**
     * @notice Deletes an employee from the contract
     * @dev Delete an employee
     * @param _employee Address of the employee to be deleted
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
     * @notice Returns the list of all employee addresses
     * @dev Get the list of all employees
     * @return employees array containing addresses of all employees
     */
    function getAllEmployees() public view returns (address[] memory employees) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        employees = ds.employeeList;
    }

    /**
     * @notice Returns the details of a specific employee
     * @dev Retrieves employee information including address, budge, and bonus
     * @param _employee Address of the employee
     * @return employee Address of the employee that will receive payment
     * @return budge Normal cash amount that will be paid to the employee
     * @return bonus Amount added as a bonus when there's not enough balance to pay the full budge
     */
    function getEmployee(address _employee) public view returns (address employee, uint256 budge, uint256 bonus) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        DiamondStorageLib.Employee memory emp = ds.employees[_employee];

        employee = emp.employee;
        budge = emp.budge;
        bonus = emp.bonus;
    }

    /**
     * @notice Returns the token balance of the bank
     * @dev Call token contract with bank address end return balance
     * @return balance The token balance of the bank
     */
    function getBalance() public returns (uint256 balance) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        token = Token(ds.token);
        balance = token.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total cost of all employees
     * @dev Sums the combined budgets and bonuses of all employees
     * @return totalCost Total cost of all employees
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
     * @dev Iterates through all employees, checking if their locktime has expired
     * @dev If locktime has expired and there's enough contract balance, transfers the employee's budget and bonus, and resets their locktime and bonus
     * @dev If there's not enough balance, the remaining balance is transferred, and the rest is added to the employee's bonus
     * @dev If there's no contract balance, the entire budget is added to the employee's bonus
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
                ds.employees[emp.employee].locktime = block.number + DiamondStorageLib.LOCKTIME_IN_BLOCKS;
                ds.employees[emp.employee].bonus = 0;
                contractBalance -= total;

                token.transfer(emp.employee, total);
                emit Paid(emp.employee, total);
            } else {
                uint256 bonus = emp.budge - contractBalance;
                ds.employees[emp.employee].bonus += bonus;

                if (contractBalance > 0) {
                    token.transfer(emp.employee, contractBalance);
                    emit Paid(emp.employee, contractBalance);

                    contractBalance = 0;
                }
                emit Bonus(emp.employee, bonus);
            }
        }
    }
}
