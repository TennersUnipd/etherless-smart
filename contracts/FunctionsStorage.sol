pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './utils.sol';

contract FunctionsStorage {
    mapping(string => Utils.Function) private deployedFunctions; // <nome funzione> -> <Function>
    string[] public availableFunctionNames;
    mapping(address => string[]) private userFunctionNames;

    function getFunctions()
        public
        view
        returns (string[] memory functionNames)
    {
        return availableFunctionNames;
    }

    function getFunctionDetails(string memory functionToSearch)
        public
        view
        returns (Utils.Function memory)
    {
        bool found = false;
        for (uint256 i = 0; i < availableFunctionNames.length; i++) {
            found = (Utils.compareStrings(availableFunctionNames[i], functionToSearch));
            if (found) {
                return deployedFunctions[availableFunctionNames[i]];
            }   
        }
        revert('Function non found');
    }

    // check if function with given name exists and return true or false
    function existsFunction(string memory named)
        public
        view
        returns (bool)
    {
        bool found = false;
        for (uint256 i = 0; i < availableFunctionNames.length; i++) {
            found = (Utils.compareStrings(availableFunctionNames[i], named));
            if (found) break;
        }
        return found;
    }



    function storeFunction(Utils.Function memory fn)
        public
    {
        // check if function already exists before adding it to the availableFunctionNames
        if (existsFunction(fn.name)) {
            revert("Function already exits and cannot be created");
        }
        // check if another funcion is already linked to remote resource
        deployedFunctions[fn.name] = fn;
        availableFunctionNames.push(fn.name);
        userFunctionNames[fn.owner].push(fn.name);
    }
}