// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IDiamondCut} from "../src/diamond/interfaces/ICut.sol";
import "../lib/forge-std/src/Script.sol";
import {Diamond} from "../src/diamond/diamond.sol";
import {Token} from "../src/facet/Token.sol";
import {Bank} from "../src/facet/Bank.sol";

contract DeployAnvil is Script {
    Bank bank;
    Token token;
    Diamond diamond;
    IDiamondCut.FacetCut[] public diamondCut;

    function run() external {
        vm.startBroadcast(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        );

        // ----------------
        // TOKEN CONTRACT
        // ----------------
        token = new Token();

        // ----------------
        // DIAMOND CONTRACT
        // ----------------
        diamond = new Diamond(address(token));

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

        bank = new Bank();

        IDiamondCut.FacetCut memory bankFaucet = IDiamondCut.FacetCut({
            facetAddress: address(bank),
            action: IDiamondCut.Action.Save,
            functionSelectors: selectors
        });

        diamondCut.push(bankFaucet);
        diamond.diamondCut(diamondCut, address(0), new bytes(0));
        vm.stopBroadcast();

        console.log("Bank", address(bank));
        console.log("Token", address(token));
        console.log("Diamond", address(diamond));
    }
}
