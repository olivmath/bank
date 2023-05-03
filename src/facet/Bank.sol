// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Token} from "./Token.sol";
import "../diamont/Diamond.Storage.Lib.sol";

contract Bank {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    address public token;

    constructor(address _token) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        ds.controller = msg.sender;
        token = _token;
    }

    modifier onlyController() {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(msg.sender == ds.controller, "NOT_AUTHORIZED");
        _;
    }

    /**
     * @dev Create a new employee
     * @param _employee address of the new employee
     * @param _budge budge amount for the employee
     */
    function createEmployee(address _employee, uint256 _budge) public onlyController {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee == address(0), "Employee already exists.");
        ds.employees[_employee] = DiamondStorageLib.Employee(_employee, _budge);
        ds.employeeList.push(_employee);
    }

    /**
     * @dev Update an employee's information
     * @param _employee address of the employee to be updated
     * @param _budge new budge amount for the employee
     */
    function updateEmployee(address _employee, uint256 _budge) public onlyController {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        require(ds.employees[_employee].employee != address(0), "Employee does not exist.");
        ds.employees[_employee].budge = _budge;
    }

    /**
     * @dev Delete an employee
     * @param _employee address of the employee to be deleted
     */
    function deleteEmployee(address _employee) public onlyController {
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
     * @return array containing addresses of all employees
     */
    function getAllEmployees() public view returns (address[] memory) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        return ds.employeeList;
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
}
