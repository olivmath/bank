// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library DiamondStorageLib {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");

    struct Employee {
        address employee;
        uint256 budge;
    }

    struct Storage {
        address controller;
        address[] employeeList;
        mapping(address => Employee) employees;
        mapping(bytes4 => address) fnSelectorToFacet;
        mapping(address => bytes4[]) facetToFnSelector;
        uint256 fnSelectorLength;
        bytes4[] allFnSelectors;
    }

    function getDiamondStorage() internal pure returns (Storage storage ds) {
        bytes32 storagePosition = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := storagePosition
        }
    }
}
