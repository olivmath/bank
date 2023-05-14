// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet} from "../../src/diamond/interfaces/Facet.types.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract LouperTest is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function testGetAddressListOfFacets() public {
        address[] memory facets = diamond.facetAddresses();

        assertEq(facets.length, 1, "Number of facets should be 1");
    }

    function testGetAddressListOfFunctions() public {
        bytes4[] memory fnSelectors = diamond.facetFunctionSelectors(address(bank));

        assertEq(fnSelectors.length, 8, "Number of facets should be 8");
    }

    function testGetFacetAddressbyFnSelectors() public {
        bytes4[] memory fnSelectors = diamond.facetFunctionSelectors(address(bank));

        for (uint256 i = 0; i < fnSelectors.length; i++) {
            address bankAddr = diamond.facetAddress(fnSelectors[i]);

            assertEq(bankAddr, address(bank), "Should return Bank address");
        }
    }

    function testGetFacets() public {
        Facet[] memory facets = diamond.facets();

        assertEq(facets.length, 1, "Should have 1 facet");
    }
}
