// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IDiamondCut} from "../src/diamont/interfaces/ICut.sol";
import {Diamond} from "../src/diamont/Diamont.sol";
import {Bank} from "../src/facet/Bank.sol";
import {Token} from "../src/facet/Token.sol";
import {Test} from "forge-std/Test.sol";

contract BaseSetup is Test {
    string seed = "test test test test test test test test test test test junk";
    bytes32 internal nextUser = keccak256(abi.encodePacked(seed));

    address[] _users;
    address controller;
    address alice;
    address bob;

    Bank bank;
    Token token;
    Diamond diamond;
    IDiamondCut.FacetCut[] public diamondCut;

    function setUp() public virtual {
        controller = address(0xffff);
        bob = address(0x1111);
        alice = address(0x2222);

        vm.label(controller, "CONTROLLER");
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");

        // ----------------
        // TOKEN CONTRACT
        // ----------------
        vm.prank(controller);
        token = new Token();

        // ----------------
        // DIAMOND CONTRACT
        // ----------------
        diamond = new Diamond();

        // ----------------
        // BANK CONTRACT
        // ----------------
        // - createEmployee(address _employee, uint256 _budge) -> void
        // - updateEmployee(address _employee, uint256 _budge) -> void
        // - deleteEmployee(address _employee) -> void
        // - getEmployee(address employee) -> (address, uint256)
        // - getAllEmployees() -> address[] memory
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = Bank.createEmployee.selector;
        selectors[1] = Bank.updateEmployee.selector;
        selectors[2] = Bank.deleteEmployee.selector;
        selectors[3] = Bank.getEmployee.selector;
        selectors[4] = Bank.getAllEmployees.selector;
        vm.prank(controller);
        bank = new Bank(address(token));

        IDiamondCut.FacetCut memory bankFaucet = IDiamondCut.FacetCut({
            facetAddress: address(bank),
            action: IDiamondCut.Action.Save,
            functionSelectors: selectors
        });

        diamondCut.push(bankFaucet);
        diamond.diamondCut(diamondCut, address(0), new bytes(0));
    }

    function getNextUserAddress() private returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    ///
    function createUsers(uint256 userNum) private returns (address payable[] memory) {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = getNextUserAddress();
            vm.deal(user, 10000 ether);
            users[i] = user;
        }
        return users;
    }
}
