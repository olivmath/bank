// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Loupe.sol";
import "./Cut.sol";
import "./Lib.sol";

contract Diamond is DiamondCut, DiamondLoupe {

    constructor() {
        DiamondStorageLib.setController(msg.sender);
    }

    receive() external payable {}

    fallback() external payable {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        // Obter o endereço da faceta correspondente ao seletor de função da chamada
        address facet = ds.fnSelectorToFacet[msg.sig];
        require(facet != address(0), "Facet not found");

        // Executar a chamada da função na faceta usando delegatecall
        assembly {
            // Copiar seletor de função e quaisquer argumentos
            calldatacopy(0, 0, calldatasize())

            // Executar a chamada da função usando a faceta
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)

            // Obter qualquer valor de retorno
            returndatacopy(0, 0, returndatasize())

            // Retornar qualquer valor de retorno ou erro de volta ao chamador
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
