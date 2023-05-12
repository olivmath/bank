// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Lib.sol";
import "./interfaces/ICut.sol";

contract DiamondCut is IDiamondCut {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    /// @notice Add/replace/remove any number of functions and optionally execute a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments _calldata is executed with delegatecall on _init
    function diamondCut(Facet[] memory _diamondCut, address _init, bytes memory _calldata) external {
        DiamondStorageLib.onlyController();
        DiamondStorageLib.diamondCut(_diamondCut, _init, _calldata);
    }
}
