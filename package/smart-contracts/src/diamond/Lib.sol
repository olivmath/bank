// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Diamond Storage Library
/// @dev This library handles the storage and manipulation of facets in a diamond contract.
/// A diamond contract is a contract that supports using multiple contract interfaces by routing function calls to the appropriate contract (facet).
import {Facet, Action} from "./interfaces/Types.sol";
import {
    CannotAddFunctionToDiamondThatAlreadyExists,
    InitializationFunctionReverted,
    CannotRemoveImmutableFunction,
    NoBytecodeAtAddress,
    FacetZeroAddress,
    FunctionNotFound,
    FnSelectorsEmpty,
    IncorrectAction,
    NoAuthorized
} from "./interfaces/Types.sol";

library DiamondStorageLib {
    /// @dev This event emits when a diamond cut has been made
    event DiamondCut(Facet[] _diamondCut, address _init, bytes _calldata);

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");
    address constant ZERO_ADDRESS = address(0x0);
    // Approximately 200 blocks per hour, 4800 blocks per day, and 144000 blocks per month
    uint256 constant LOCKTIME_IN_BLOCKS = 144000;

    /// @dev Employee structure to hold employee details
    struct Employee {
        address employee;
        uint256 budge;
        uint256 locktime;
        uint256 bonus;
    }

    /// @dev Information about facet
    struct AboutFacet {
        address facet;
        /// @dev index of this fnSelector (key) in the list of selectors for this facet (value).
        uint256 fnSelectorsID;
    }

    /// @dev Information about function selectors
    struct AboutFnSelectors {
        bytes4[] fnSelectors;
        /// @dev index of the facet (key) that contains these selectors (value) => `address[] facets`
        uint256 facetAddressID;
    }

    /// @dev Storage structure to hold state variables
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

    /// @notice This function retrieves the diamond storage struct which is declared in a specific storage slot.
    /// @dev The diamond storage struct is stored at a specific storage slot to prevent clashes with other state variables in the contract.
    /// @return ds Returns an instance of the Storage struct (representing the diamond storage).
    function getDiamondStorage() internal pure returns (Storage storage ds) {
        bytes32 storagePosition = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := storagePosition
        }
    }

    /// @notice This function is used to set a new controller in the diamond storage.
    /// @dev This function first retrieves the diamond storage struct and then updates the controller property.
    /// @param newController The address of the new controller.
    function setController(address newController) internal {
        Storage storage ds = getDiamondStorage();
        ds.controller = newController;
    }

    /// @notice This function is used to get the controller address from the diamond storage.
    /// @dev This function retrieves the diamond storage struct and returns the controller property.
    /// @return The address of the controller.
    function controller() internal view returns (address) {
        return getDiamondStorage().controller;
    }

    /// @notice This function is used to set the token address in the diamond storage.
    /// @dev It retrieves the diamond storage struct and sets the token property to the address provided as a parameter.
    /// @param newToken The address of the new token to be set in the diamond storage.
    function setToken(address newToken) public {
        Storage storage ds = getDiamondStorage();
        ds.token = newToken;
    }

    /// @notice This function retrieves the token address from the diamond storage.
    /// @dev It retrieves the diamond storage struct and returns the token property.
    /// @return The address of the token stored in the diamond storage.
    function token() internal view returns (address) {
        return getDiamondStorage().token;
    }

    /// @notice This function verifies if the caller is the current controller of the contract.
    /// @dev It retrieves the controller address from the diamond storage and compares it with the caller's address (msg.sender).
    /// @dev If the addresses are not the same, it reverts the transaction with the NotAuthorized error.
    /// @custom:require The function requires that the caller's address is the same as the controller's address.
    function onlyController() internal view {
        Storage storage ds = getDiamondStorage();
        if (ds.controller != msg.sender) {
            revert NoAuthorized();
        }
    }

    /// @dev Performs a diamond cut, which adds, replaces or removes one or more functions.
    /// @param _diamondCut Contains data about the function(s) being added, replaced or removed.
    /// @param _init The address of an initialization contract that initializes state variables. This is can be address(0) which means no initialization.
    /// @param _calldata A function call, including function selector and arguments, that is executed with delegatecall.
    function diamondCut(Facet[] memory _diamondCut, address _init, bytes memory _calldata) internal {
        // iterate over all facets
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            Action action = _diamondCut[facetIndex].action;

            if (action == Action.Save) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Modify) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else {
                revert IncorrectAction(uint8(action));
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
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

    /*////////////////////////////////////////////////////////////
                                                    SAVE FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function is responsible for adding new function selectors to a facet.
    /// @dev It checks if the provided function selectors are valid, if the facet address is not zero and if the facet does not already contain the function selectors.
    /// @dev If these conditions are met, the function selectors are added to the facet.
    /// @param _facetAddress The address of the facet to which the function selectors will be added.
    /// @param _fnSelectors An array of function selectors that will be added to the facet.
    /// @custom:require _fnSelectors array must not be empty.
    /// @custom:require _facetAddress must not be a zero address.
    /// @custom:require The function selectors must not already exist in the facet.
    function addFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        // error handling
        if (_fnSelectors.length <= 0) {
            revert FnSelectorsEmpty();
        } else if (_facetAddress == ZERO_ADDRESS) {
            revert FacetZeroAddress(
                _facetAddress, "function: addFunctions(address _facetAddress, bytes4[] memory _fnSelectors)"
            );
        }

        // adding functions
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

    /// @notice This function is responsible for adding a new facet to the contract's storage.
    /// @dev It checks if the provided facet address contains contract code.
    /// @param ds The instance of the contract's storage.
    /// @param _facetAddress The address of the new facet.
    /// @custom:require _facetAddress must contain contract code.
    function addFacet(Storage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "function: addFacet(), result: New facet");

        ds.facetToFnSelectors[_facetAddress].facetAddressID = ds.facets.length;
        ds.facets.push(_facetAddress);
        ds.facetsLength++;
    }

    /// @notice This function is responsible for adding a new function to the contract's storage.
    /// @dev It maps the function selector to the facet and updates the storage.
    /// @param ds The instance of the contract's storage.
    /// @param _selector The function selector that will be added.
    /// @param _selectorPosition The position of the function selector in the list.
    /// @param _facetAddress The address of the facet where the function resides.
    function addFunction(Storage storage ds, bytes4 _selector, uint256 _selectorPosition, address _facetAddress)
        internal
    {
        ds.fnSelectorToFacet[_selector].fnSelectorsID = _selectorPosition;
        ds.facetToFnSelectors[_facetAddress].fnSelectors.push(_selector);
        ds.fnSelectorToFacet[_selector].facet = _facetAddress;
        ds.fnSelectorLength++;
    }

    /*////////////////////////////////////////////////////////////
                                                  MODIFY FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @dev This function replaces a list of function selectors with a new facet address.
    /// @param _facetAddress The new facet address that the function selectors should be associated with.
    /// @param _fnSelectors The list of function selectors to be replaced.
    /// Requirements:
    /// - `_fnSelectors` must not be an empty array.
    /// - `_facetAddress` must be a non-zero address.
    /// Errors:
    /// - Emits a `FnSelectorsEmpty` error if `_fnSelectors` is an empty array.
    /// - Emits a `FacetZeroAddress` error if `_facetAddress` is a zero address.
    /// - Emits a `CannotAddFunctionToDiamondThatAlreadyExists` error if a function selector is already associated with `_facetAddress`.
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

    /*////////////////////////////////////////////////////////////
                                                  REMOVE FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @dev This function removes a single function selector from a specific facet address.
    /// @param ds A reference to the storage slot where the diamond storage structure resides.
    /// @param _facetAddress The facet address that the function selector should be removed from. This must be a non-zero address and not the address of the current contract.
    /// @param _selector The function selector to be removed.
    /// Requirements:
    /// - `_facetAddress` must be a non-zero address.
    /// - `_facetAddress` must not be the address of the current contract.
    /// - `_selector` must be a valid function selector associated with `_facetAddress`.
    /// Errors:
    /// - Emits a `FacetZeroAddress` error if `_facetAddress` is a zero address.
    /// - Emits a `CannotRemoveImmutableFunction` error if `_facetAddress` is the address of the current contract.
    /// Notes:
    /// - If a function selector does not exist, it will not throw an error. It will just continue to the next operation.
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

    /// @dev This function removes a batch of functions for a specific facet address. The removal involves clearing out function selectors associated with this facet.
    /// @param _facetAddress The facet address that the function selectors should be removed from. This must be a non-zero address.
    /// @param _fnSelectors An array of function selectors that are to be removed. This array must not be empty.
    /// Requirements:
    /// - `_facetAddress` must be a non-zero address.
    /// - `_fnSelectors` array must not be empty.
    /// Errors:
    /// - Emits a `FnSelectorsEmpty` error if the `_fnSelectors` array is empty.
    /// - Emits a `FacetZeroAddress` error if `_facetAddress` is a zero address.
    /// Notes:
    /// - If a function selector does not exist, it will not throw an error. It will just continue to the next function selector.
    function removeFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        if (_fnSelectors.length <= 0) {
            revert FnSelectorsEmpty();
        }

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
