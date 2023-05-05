// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseSetup} from "../BaseSetup.sol";

contract BaseBankTest is BaseSetup {
    bytes4 public createEmployee;
    bytes4 public updateEmployee;
    bytes4 public deleteEmployee;
    bytes4 public getAllEmployees;
    bytes4 public getEmployee;

    uint256 public bobBudge;
    uint256 public aliceBudge;
    uint256 public eveBudge;
    uint256 public locktime;

    function setUp() public virtual override {
        // ----------------
        // BANK CONTRACT
        // ----------------
        // 0x520a19c0  =>  createEmployee(address,uint256)
        // 0x5e91d8ec  =>  updateEmployee(address,uint256)
        // 0x6e7c4ab1  =>  deleteEmployee(address)
        // 0xe3366fed  =>  getAllEmployees() -> address[] memory
        // 0x32648e09  =>  getEmployee(address) -> (address, uint256)
        createEmployee = 0x520a19c0;
        updateEmployee = 0x5e91d8ec;
        deleteEmployee = 0x6e7c4ab1;
        getAllEmployees = 0xe3366fed;
        getEmployee = 0x32648e09;

        bobBudge = 5000 * 10e18;
        aliceBudge = 20 * 10e18;
        eveBudge = 30 * 10e18;

        BaseSetup.setUp();
    }
}
