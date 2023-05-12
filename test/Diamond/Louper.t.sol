// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet} from "../../src/diamond/interfaces/Facet.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract LouperTest is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function testGetFacets() public {}
}
