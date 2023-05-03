// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Token} from "./Token.sol";

contract Bank {
    address public token;

    struct Employee {
        address employee;
        uint256 budge;
    }

    address public controller;
    mapping(address => Employee) public employees;
    address[] public employeeList;

    constructor(address _token) {
        controller = msg.sender;
        token = _token;
    }

    modifier onlyController() {
        require(msg.sender == controller, "NOT_AUTHORIZED");
        _;
    }

    /**
     * @dev Create a new employee
     * @param _employee address of the new employee
     * @param _budge budge amount for the employee
     */
    function createEmployee(address _employee, uint256 _budge) public onlyController {
        require(employees[_employee].employee == address(0), "Employee already exists.");
        employees[_employee] = Employee(_employee, _budge);
        employeeList.push(_employee);
    }

    /**
     * @dev Update an employee's information
     * @param _employee address of the employee to be updated
     * @param _budge new budge amount for the employee
     */
    function updateEmployee(address _employee, uint256 _budge) public onlyController {
        require(employees[_employee].employee != address(0), "Employee does not exist.");
        employees[_employee].budge = _budge;
    }

    /**
     * @dev Delete an employee
     * @param _employee address of the employee to be deleted
     */
    function deleteEmployee(address _employee) public onlyController {
        require(employees[_employee].employee != address(0), "Employee does not exist.");
        delete employees[_employee];

        // Remove employee from employeeList
        for (uint256 i = 0; i < employeeList.length; i++) {
            if (employeeList[i] == _employee) {
                employeeList[i] = employeeList[employeeList.length - 1];
                employeeList.pop();
                break;
            }
        }
    }

    /**
     * @dev Get the list of all employees
     * @return array containing addresses of all employees
     */
    function getAllEmployees() public view returns (address[] memory) {
        return employeeList;
    }

    /**
     * @dev Get a employee
     * @return address and budge of a employee
     */
    function getEmployee(address employee) public view returns (address, uint256) {
        Employee memory emp = employees[employee];
        return (emp.employee, emp.budge);
    }
}
