pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './Utils.sol';

contract FunctionsStorage {

    struct Function {
        string name;
        string description;
        string prototype;
        uint256 cost; // in wei
        address payable owner;
        string remoteResource;
    }

    mapping(string => Function) private deployedFunctions; // <nome funzione> -> <Function>
    string[] private availableFunctionNames;
    mapping(address => string[]) private userFunctionNames;

    function getFunctionDetails(string memory functionToSearch)
        public
        view
        returns (Function memory)
    {
        (uint256 index, bool exists) = indexOfFunction(functionToSearch);
        if (!exists) {
            revert("Function not found");
        }
        return deployedFunctions[availableFunctionNames[index]];
    }

    function indexOfFunction(string memory named)
        private
        view
        returns (uint256, bool)
    {
        for (uint256 i = 0; i < availableFunctionNames.length; i++) {
            if (Utils.compareStrings(availableFunctionNames[i], named))
                return(i,true);
        }
        return(0,false);
    }

    // check if function with given name exists and return true or false
    function existsFunction(string memory named)
        public
        view
        returns (bool)
    {
        (, bool exists) = indexOfFunction(named);
        return exists;
    }

    function storeFunction(Function memory fn)
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

    function getFunctions()
        public
        view
        returns (Function[] memory functionNames)
    {
        uint totalFunctions = availableFunctionNames.length;
        Function[] memory results = new Function[](totalFunctions);
        for (uint256 i = 0; i < totalFunctions; i++) {
            results[i] = deployedFunctions[availableFunctionNames[i]];
        }
        return results;
    }

    function setFunction(string memory fnName,
        string memory description,
        string memory prototype,
        uint256 cost
        )
        public
        {
        if (!existsFunction(fnName)) {
            revert("Function doesn't exist");
        }
        deployedFunctions[fnName].description = description;
        deployedFunctions[fnName].prototype = prototype;
        deployedFunctions[fnName].cost = cost;
        }

    function costOfFunction(string memory fnName)
        public
        view
        returns (uint256 cost)
    {
        Function memory fnRequested = getFunctionDetails(fnName);
        return fnRequested.cost;
    }

    function buildFunction(
        string memory name,
        string memory description,
        string memory prototype,
        uint256 cost,
        string memory remoteResource,
        address payable owner)
        public
        pure
        returns (Function memory)
    {
        return Function({
            name: name,
            description: description,
            prototype: prototype,
            cost: cost,
            owner: owner,
            remoteResource: remoteResource
        });
    }
}
