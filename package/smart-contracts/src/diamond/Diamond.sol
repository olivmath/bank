// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FunctionNotFound, DiamondStorageLib} from "./Lib.sol";
import {Louper} from "./Louper.sol";
import {Cutter} from "./Cutter.sol";

/// @title Diamond Contract
/// @dev This contract uses the Diamond pattern, allowing for modular code and multiple facets
contract Diamond is Cutter, Louper {
    /// @notice Creates a new diamond contract
    /// @dev This function sets the controller of the diamond to the sender of this transaction
    /// and sets the token of the DiamondStorageLib
    /// @param token The address of the token to be set in the DiamondStorageLib
    constructor(address token) {
        DiamondStorageLib.setController(msg.sender);
        DiamondStorageLib.setToken(token);
    }

    /// @notice Function to receive Ether
    /// @dev This function is executed when the contract receives plain Ether (without data)
    receive() external payable {}

    /// @notice Fallback function
    /// @dev This function is executed if the contract was called with data but without a matching function
    fallback() external payable {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        // Get the facet address corresponding to the function selector of the call
        address facet = ds.fnSelectorToFacet[msg.sig].facet;
        if (facet == DiamondStorageLib.ZERO_ADDRESS) {
            revert FunctionNotFound(msg.sig);
        }

        // Execute the function call on the facet using delegatecall
        assembly {
            // Copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // Execute the function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)

            // Get any return value
            returndatacopy(0, 0, returndatasize())

            // Return any return value or error back to the caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
