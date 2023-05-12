// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet, Action} from "../../src/diamond/interfaces/Facet.types.sol";
import {FunctionNotFound} from "../../src/diamond/Lib.sol";
import {BankV2} from "../../src/facet/Bank.v2.sol";
import {BankV3} from "../../src/facet/Bank.v3.sol";
import {Bank} from "../../src/facet/Bank.sol";
import {BaseSetup} from "../BaseSetup.sol";


contract CutTest is BaseSetup {
    BankV2 bankv2;
    Facet bankV2FacetSave;
    Facet bankV2FacetModity;

    Facet[] diamondCutV2;
    Facet[] diamondCutV3;

    function setUp() public virtual override {
        BaseSetup.setUp();

        // ----------------
        // BANK V2 CONTRACT FACET
        // ----------------
        // [Modify] 0x809e9ef5  =>  payAllEmployees()
        // [Save]   0x708f29a6  =>  getTotalPayments()

        bytes4[] memory selectorsModify = new bytes4[](1);
        selectorsModify[0] = BankV2.payAllEmployees.selector;

        bytes4[] memory selectorsSave = new bytes4[](1);
        selectorsSave[0] = BankV2.getTotalPayments.selector;

        vm.prank(controller);
        bankv2 = new BankV2();

        bankV2FacetSave = Facet({facetAddress: address(bankv2), action: Action.Save, fnSelectors: selectorsSave});
        bankV2FacetModity = Facet({facetAddress: address(bankv2), action: Action.Modify, fnSelectors: selectorsModify});
    }

    function testAddFacet() public {
        diamondCutV2.push(bankV2FacetSave);

        vm.prank(controller);
        diamond.diamondCut(diamondCutV2, address(0x0), new bytes(0));

        Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 2, "Should have 2 Facets");
    }

    function testModifyFacetToV2() public {
        diamondCutV2.push(bankV2FacetModity);

        vm.prank(controller);
        diamond.diamondCut(diamondCutV2, address(0x0), new bytes(0));

        Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 2, "Should have 2 Facets");
    }

    function testModifyFacetToV3() public {
        bytes4[] memory selectorsModifyV3 = new bytes4[](1);
        selectorsModifyV3[0] = BankV3.payAllEmployees.selector;

        BankV3 bankv3 = new BankV3();

        Facet memory bankv3FacetModify =
            Facet({facetAddress: address(bankv3), action: Action.Modify, fnSelectors: selectorsModifyV3});
        diamondCutV3.push(bankv3FacetModify);

        vm.prank(controller);
        diamond.diamondCut(diamondCutV3, address(0x0), new bytes(0));

        Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 2, "Should have 2 Facets");

        (bool ok, bytes memory data) = address(diamond).call(abi.encodeWithSelector(BankV2.payAllEmployees.selector));
        assertTrue(ok, "Should can call function BankV2.payAllEmployees");
        uint256 result = abi.decode(data, (uint256));

        assertEq(result, 3, "Should return 2");
    }

    function testRemoveFunction() public {
        bytes4[] memory selectorsRemove = new bytes4[](1);
        selectorsRemove[0] = Bank.deleteEmployee.selector;

        Facet memory bankV2FacetRemove =
            Facet({facetAddress: address(0), action: Action.Remove, fnSelectors: selectorsRemove});
        diamondCutV2.push(bankV2FacetRemove);

        vm.prank(controller);
        diamond.diamondCut(diamondCutV2, address(0x0), new bytes(0));

        Facet[] memory facets = diamond.facets();
        assertEq(facets.length, 1, "Should have 1 Facet after removal");
        assertEq(facets[0].fnSelectors.length, 7, "Should have 7 Facet after removal");

        (bool ok, bytes memory data) = address(diamond).call(abi.encodeWithSelector(Bank.deleteEmployee.selector));
        assertEq(ok, false, "Should not be able to call function BankV2.payAllEmployees after removal");

        bytes memory expectedRevertData =
            abi.encodeWithSelector(FunctionNotFound.selector, Bank.deleteEmployee.selector);
        assertEq(data, expectedRevertData, "Returned data did not match expected revert data");
    }
}
