// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DiamondStorageLib} from "../src/diamont/Lib.sol";
import {Token} from "../src/facet/Token.sol";
import {Bank} from "../src/facet/Bank.sol";
import {BaseSetup} from "./BaseSetup.sol";

contract Attack {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    function erase() public {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        while (ds.employeeList.length > 0) {
            ds.employeeList.pop();
        }
    }

    function stealOwnership(address thief) public {
        DiamondStorageLib.setController(thief);
    }
}

contract SecBankTest is BaseSetup {
    Attack public attacker;

    // ----------------
    // BANK CONTRACT
    // ----------------
    // 0x520a19c0  =>  createEmployee(address,uint256)
    // 0x5e91d8ec  =>  updateEmployee(address,uint256)
    // 0x6e7c4ab1  =>  deleteEmployee(address)
    // 0xe3366fed  =>  getAllEmployees() -> address[] memory
    // 0x32648e09  =>  getEmployee(address) -> (address, uint256)
    bytes4 createEmployee = 0x520a19c0;
    bytes4 updateEmployee = 0x5e91d8ec;
    bytes4 deleteEmployee = 0x6e7c4ab1;
    bytes4 getAllEmployees = 0xe3366fed;
    bytes4 getEmployee = 0x32648e09;

    function setUp() public virtual override {
        BaseSetup.setUp();

        attacker = new Attack();
    }

    function testEraseEmployeeData() public {
        vm.startPrank(controller);
        address(diamond).call(abi.encodeWithSelector(createEmployee, alice, 1000 * 10e18));
        address(diamond).call(abi.encodeWithSelector(createEmployee, bob, 2000 * 10e18));
        address(diamond).call(abi.encodeWithSelector(createEmployee, address(0x3333), 3000 * 10e18));
        vm.stopPrank();

        // Burn data
        attacker.erase();

        // Verify empty data
        (, bytes memory data2) = address(diamond).call(abi.encodeWithSelector(getAllEmployees));
        address[] memory employees = abi.decode(data2, (address[]));

        assertTrue(employees.length == 3, "Hacker managed to corrupt the memory");
    }

    function testStealOwnership() public {
        address thief = address(0x4545);
        attacker.stealOwnership(thief);

        vm.prank(thief);
        (bool success,) = address(diamond).call(abi.encodeWithSelector(createEmployee, bob, 5000));
        assertFalse(success, "Thief managed to steal the ownership");
    }
}
