// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet, Action} from "../src/diamond/interfaces/Types.sol";
import {FrontErrors} from "../src/facet/FrontErrors.sol";
import {Diamond} from "../src/diamond/Diamond.sol";
import {BankV2} from "../src/facet/Bank.v2.sol";
import {Token} from "../src/facet/Token.sol";
import {Bank} from "../src/facet/Bank.sol";
import "../lib/forge-std/src/Script.sol";

contract DeployAnvil is Script {
    FrontErrors front;
    BankV2 bankv2;
    Bank bankv1;
    Token token;
    Diamond diamond;
    Facet[] diamondCutV1;
    Facet[] diamondCutV2;
    Facet[] diamondCutV3;

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

        bankv1 = new Bank();

        Facet memory bankV1Facet = Facet({
            facetAddress: address(bankv1),
            action: Action.Save,
            fnSelectors: selectors
        });

        diamondCutV1.push(bankV1Facet);
        diamond.diamondCut(diamondCutV1, address(0), new bytes(0));

        console.log("BankV1", address(bankv1));
        console.log("Token", address(token));
        console.log("Diamond", address(diamond));

        // ----------------
        // BANK V2 CONTRACT FACET
        // ----------------
        // [Modify] 0x809e9ef5  =>  payAllEmployees()
        // [Save]   0x708f29a6  =>  getTotalPayments()
        bytes4[] memory selectorsModify = new bytes4[](1);
        selectorsModify[0] = BankV2.payAllEmployees.selector;

        bytes4[] memory selectorsSave = new bytes4[](1);
        selectorsSave[0] = BankV2.getTotalPayments.selector;

        bankv2 = new BankV2();
        console.log("BankV2", address(bankv2));


        Facet memory bankV2FacetSave = Facet({facetAddress: address(bankv2), action: Action.Save, fnSelectors: selectorsSave});
        Facet memory bankV2FacetModity = Facet({facetAddress: address(bankv2), action: Action.Modify, fnSelectors: selectorsModify});

        diamondCutV2.push(bankV2FacetSave);
        diamondCutV2.push(bankV2FacetModity);

        diamond.diamondCut(diamondCutV2, address(0), new bytes(0));


        // ----------------
        // FRONT ERRORS CONTRACT FACET
        // ----------------
        // 0xaa78da13  =>  withMultipleArgs()
        // 0xf259030d  =>  withStringArgs()
        // 0x15218ec1  =>  withBoolArgs()
        // 0xc9294df0  =>  withUintArgs()
        // 0xa74d06f9  =>  withoutArgs()
        // 0xff9aea68  =>  requireString()  

        bytes4[] memory selectorsFront = new bytes4[](6);
        selectorsFront[0] = FrontErrors.withMultipleArgs.selector;
        selectorsFront[1] = FrontErrors.withStringArgs.selector;
        selectorsFront[2] = FrontErrors.withBoolArgs.selector;
        selectorsFront[3] = FrontErrors.withUintArgs.selector;
        selectorsFront[4] = FrontErrors.withoutArgs.selector;
        selectorsFront[5] = FrontErrors.requireString.selector;

        front = new FrontErrors();
        console.log("FrontErrors", address(front));

        Facet memory frontFacet = Facet({facetAddress: address(front), action: Action.Save, fnSelectors: selectorsFront});
        diamondCutV3.push(frontFacet);

        diamond.diamondCut(diamondCutV3, address(0), new bytes(0));

        vm.stopBroadcast();
    }
}
