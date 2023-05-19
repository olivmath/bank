// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Facet, Action} from "./interfaces/Types.sol";
import {
    InitializationFunctionReverted,
    CannotAddFunctionToDiamondThatAlreadyExists,
    FacetZeroAddress,
    NoBytecodeAtAddress,
    CannotRemoveImmutableFunction,
    FunctionNotFound,
    IncorrectAction,
    FnSelectorsEmpty
} from "./interfaces/Types.sol";

library DiamondStorageLib {
    ////////////////////////////////////////////////////////////////
    //////////////// EVENTS
    ////////////////////////////////////////////////////////////////

    event DiamondCut(Facet[] _diamondCut, address _init, bytes _calldata);

    // Approximately 200 blocks per hour, 4800 blocks per day, and 144000 blocks per month
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");
    address constant ZERO_ADDRESS = address(0x0);
    uint256 constant LOCKTIME_IN_BLOCKS = 10;

    ////////////////////////////////////////////////////////////////
    //////////////// STRUCTS
    ////////////////////////////////////////////////////////////////

    struct Employee {
        address employee;
        uint256 budge;
        uint256 locktime;
        uint256 bonus;
    }

    struct AboutFacet {
        address facet;
        /// index of this fnSelector (key) in the list of selectors for this facet (value).
        /// @dev facetToFnSelector.fnSelectors[fnSelectorsID]
        uint256 fnSelectorsID;
    }

    struct AboutFnSelectors {
        bytes4[] fnSelectors;
        /// index of the facet (key) that contains these selectors (value) => `address[] facets`
        /// @dev facets[facetAddressID]
        uint256 facetAddressID;
    }

    struct Storage {
        mapping(address => Employee) employees;
        uint256 paymentsCounter;
        address[] employeeList;
        address controller;
        address token;
        //
        mapping(bytes4 => AboutFacet) fnSelectorToFacet;
        mapping(address => AboutFnSelectors) facetToFnSelectors;
        // all selectors add in diamond
        bytes4[] fnSelectors;
        uint256 fnSelectorLength;
        // all address of contracts add in diamond called `facet`
        address[] facets;
        uint256 facetsLength;
    }

    ////////////////////////////////////////////////////////////////
    //////////////// FUNCTIONS
    ////////////////////////////////////////////////////////////////

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

    function setToken(address newToken) public {
        Storage storage ds = getDiamondStorage();
        ds.token = newToken;
    }

    function token() internal view returns (address) {
        return getDiamondStorage().token;
    }

    function onlyController() internal view {
        require(getDiamondStorage().controller == msg.sender, "NOT_AUTHORIZED");
    }

    ////////////////////////////////////////////////////////////////
    //////////////// DIAMOND CUT
    ////////////////////////////////////////////////////////////////

    event log_string(string msg);

    function diamondCut(Facet[] memory _diamondCut, address _init, bytes memory _calldata) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            Action action = _diamondCut[facetIndex].action;

            if (action == Action.Save) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Modify) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Remove) {
                // removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else {
                revert IncorrectAction(uint8(action));
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        if (_fnSelectors.length <= 0) {
            revert FnSelectorsEmpty();
        } else if (_facetAddress == ZERO_ADDRESS) {
            revert FacetZeroAddress(
                _facetAddress, "function: addFunctions(address _facetAddress, bytes4[] memory _fnSelectors)"
            );
        }

        Storage storage ds = getDiamondStorage();

        uint256 fnSelectorsCounter = uint256(ds.facetToFnSelectors[_facetAddress].fnSelectors.length);

        // add new facet address if it does not exist
        if (fnSelectorsCounter == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = ds.fnSelectorToFacet[selector].facet;
            if (oldFacetAddress != ZERO_ADDRESS) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            addFunction(ds, selector, fnSelectorsCounter, _facetAddress);
            fnSelectorsCounter++;
        }
    }

    function addFacet(Storage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "function: addFacet(), result: New facet");

        ds.facetToFnSelectors[_facetAddress].facetAddressID = ds.facets.length;
        ds.facets.push(_facetAddress);
        ds.facetsLength++;
    }

    function addFunction(Storage storage ds, bytes4 _selector, uint256 _selectorPosition, address _facetAddress)
        internal
    {
        ds.fnSelectorToFacet[_selector].fnSelectorsID = _selectorPosition;
        ds.facetToFnSelectors[_facetAddress].fnSelectors.push(_selector);
        ds.fnSelectorToFacet[_selector].facet = _facetAddress;
        ds.fnSelectorLength++;
    }

    function enforceHasContractCode(address _contract, string memory debugMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert NoBytecodeAtAddress(_contract, debugMessage);
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == ZERO_ADDRESS) {
            return;
        }

        enforceHasContractCode(
            _init, "function: initializeDiamondCut(address _init, bytes memory _calldata), result:_init contract"
        );

        (bool success, bytes memory error) = _init.delegatecall(_calldata);

        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(_init, _calldata);
            }
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        if (_fnSelectors.length <= 0) {
            revert FnSelectorsEmpty();
        } else if (_facetAddress == ZERO_ADDRESS) {
            revert FacetZeroAddress(
                _facetAddress, "function: replaceFunctions(address _facetAddress, bytes4[] memory _fnSelectors)"
            );
        }
        Storage storage ds = getDiamondStorage();
        uint256 fnSelectorsCounter = uint256(ds.facetToFnSelectors[_facetAddress].fnSelectors.length);
        if (fnSelectorsCounter == 0) {
            addFacet(ds, _facetAddress);
        }

        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = ds.fnSelectorToFacet[selector].facet;
            if (oldFacetAddress == _facetAddress) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, fnSelectorsCounter, _facetAddress);
            fnSelectorsCounter++;
        }
    }

    function removeFunction(Storage storage ds, address _facetAddress, bytes4 _selector) internal {
        if (_facetAddress == ZERO_ADDRESS) {
            revert FacetZeroAddress(
                _facetAddress, "function: removeFunction(Storage storage ds, address _facetAddress, bytes4 _selector)"
            );
        }
        if (_facetAddress == address(this)) {
            revert CannotRemoveImmutableFunction(_facetAddress);
        }

        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.fnSelectorToFacet[_selector].fnSelectorsID;
        uint256 lastSelectorPosition = ds.facetToFnSelectors[_facetAddress].fnSelectors.length - 1;

        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetToFnSelectors[_facetAddress].fnSelectors[lastSelectorPosition];
            ds.facetToFnSelectors[_facetAddress].fnSelectors[selectorPosition] = lastSelector;
            ds.fnSelectorToFacet[lastSelector].fnSelectorsID = uint96(selectorPosition);
        }

        // delete the last selector
        ds.facetToFnSelectors[_facetAddress].fnSelectors.pop();
        delete ds.fnSelectorToFacet[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastfacetAddressID = ds.facetsLength;
            uint256 facetAddressID = ds.facetToFnSelectors[_facetAddress].facetAddressID;

            if (facetAddressID != lastfacetAddressID) {
                address lastFacetAddress = ds.facets[lastfacetAddressID];
                ds.facets[facetAddressID] = lastFacetAddress;
                ds.facetToFnSelectors[lastFacetAddress].facetAddressID = facetAddressID;
            }

            ds.facets.pop();
            delete ds.facetToFnSelectors[_facetAddress].facetAddressID;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        if (_fnSelectors.length <= 0) {
            revert FnSelectorsEmpty();
        }

        // if function does not exist then do nothing and return
        if (_facetAddress != address(0)) {
            revert FacetZeroAddress(
                _facetAddress, "function: removeFunctions(address _facetAddress, bytes4[] memory _fnSelectors)"
            );
        }

        Storage storage ds = getDiamondStorage();
        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = ds.fnSelectorToFacet[selector].facet;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }
}
