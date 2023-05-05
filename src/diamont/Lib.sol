// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library DiamondStorageLib {
    // Approximately 200 blocks per hour, 4800 blocks per day, and 144000 blocks per month
    uint256 constant LOCKTIME_IN_BLOCKS = 144000;
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");

    struct Employee {
        address employee;
        uint256 budge;
        uint256 locktime;
    }

    struct Storage {
        mapping(address => Employee) employees;
        address[] employeeList;
        address controller;
        address token;
        //
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

    function setController(address newController) internal {
        Storage storage ds = getDiamondStorage();
        ds.controller = newController;
    }

    function controller() internal view returns (address) {
        return getDiamondStorage().controller;
    }

    function token() internal view returns (address) {
        return getDiamondStorage().token;
    }

    function onlyController() internal view {
        require(getDiamondStorage().controller == msg.sender, "NOT_AUTHORIZED");
    }
}
