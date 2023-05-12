// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IDiamondCut {
    enum Action {
        Save,
        Modify,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        Action action;
        bytes4[] functionSelectors;
    }

    event DiamondCuted(bytes[] _diamondCut, address _init, bytes _calldata);

    /// @notice Add/replace/remove any number of functions and optionally execute a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments _calldata is executed with delegatecall on _init
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
}
