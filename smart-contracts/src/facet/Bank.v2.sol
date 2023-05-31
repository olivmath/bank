// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DiamondStorageLib} from "../diamond/Lib.sol";
import {ERC20} from "../facet/Token.sol";
import {Token} from "./Token.sol";

error NothingToPay();

/**
 * @title Bank
 * @notice A contract to manage employee budgets using the Diamond Storage Library
 */
contract BankV2 {
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

        bool payed = false;

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
                payed = true;
            } else {
                uint256 bonus = emp.budge - contractBalance;
                ds.employees[emp.employee].bonus += bonus;

                if (contractBalance > 0) {
                    token.transfer(emp.employee, contractBalance);
                    emit Paid(emp.employee, contractBalance);

                    contractBalance = 0;
                    payed = true;
                }
                emit Bonus(emp.employee, bonus);
            }
        }

        if (payed == false) {
            revert NothingToPay();
        }
    }

    /**
     * @dev Returns the total number of payments made
     * @return pay The total number of payments made
     */

    function getTotalPayments() external view returns (uint256 pay) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        pay = ds.paymentsCounter;
    }
}
