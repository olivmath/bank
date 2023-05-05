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
    address eve;
    address zero;

    Bank bank;
    Token token;
    Diamond diamond;
    IDiamondCut.FacetCut[] public diamondCut;

    function setUp() public virtual {
        controller = address(0xffff);
        bob = address(0x1111);
        alice = address(0x2222);
        eve = address(0x3333);
        zero = address(0x0);

        vm.label(controller, "CONTROLLER");
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");
        vm.label(eve, "EVE");
        vm.label(zero, "ZERO");

        // ----------------
        // TOKEN CONTRACT
        // ----------------
        vm.prank(controller);
        token = new Token();

        // ----------------
        // DIAMOND CONTRACT
        // ----------------
        vm.prank(controller);
        diamond = new Diamond();

        // ----------------
        // BANK CONTRACT
        // ----------------
        // 0x520a19c0  =>  createEmployee(address,uint256)
        // 0x5e91d8ec  =>  updateEmployee(address,uint256)
        // 0x6e7c4ab1  =>  deleteEmployee(address)
        // 0xe3366fed  =>  getAllEmployees() -> address[] memory
        // 0x32648e09  =>  getEmployee(address) -> (address, uint256)
        // 0x809e9ef5  =>  payAllEmployees()
        // 0x12065fe0  =>  getBalance()
        // 0x1e153139  =>  getTotalEmployeeCost()
        bytes4[] memory selectors = new bytes4[](8);
        selectors[0] = Bank.createEmployee.selector;
        selectors[1] = Bank.updateEmployee.selector;
        selectors[2] = Bank.deleteEmployee.selector;
        selectors[3] = Bank.getEmployee.selector;
        selectors[4] = Bank.getAllEmployees.selector;
        selectors[5] = Bank.payAllEmployees.selector;
        selectors[6] = Bank.getBalance.selector;
        selectors[7] = Bank.getTotalEmployeeCost.selector;
        vm.prank(controller);
        bank = new Bank(address(token));

        IDiamondCut.FacetCut memory bankFaucet = IDiamondCut.FacetCut({
            facetAddress: address(bank),
            action: IDiamondCut.Action.Save,
            functionSelectors: selectors
        });

        diamondCut.push(bankFaucet);

        vm.prank(controller);
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
