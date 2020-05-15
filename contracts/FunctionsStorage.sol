pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './Utils.sol';

// A contract used for storing and handling stored functions
contract FunctionsStorage {

    // Rapresents a functino with all its properties to be stored
    struct Function {
        string name;
        string description;
        string prototype;
        uint256 cost; // in wei
        address payable owner;
        string remoteResource;
    }

    mapping(string => Function) private deployedFunctions; // <function name> -> <Function>
    string[] private availableFunctionNames;
    mapping(address => string[]) private userFunctionNames; // <owner address> -> <owned functions array>
    
    // Retrieves details for a given function
    // If name is invalid, a function not found error is triggered
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

    // Searches for the position of a function
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

    // Checks if function with given name exists
    function existsFunction(string memory named)
        public
        view
        returns (bool)
    {
        (, bool exists) = indexOfFunction(named);
        return exists;
    }

    // Stores a new function
    // This should be the only way to add a new function to the storage as it ensures all storage variable are correctly manipulated
    function storeFunction(Function memory fn)
        public
    {
        // check if function already exists before adding it to the availableFunctionNames
        if (existsFunction(fn.name)) {
            revert("Function already exist and cannot be created");
        }
        // check if another funcion is already linked to remote resource
        deployedFunctions[fn.name] = fn;
        availableFunctionNames.push(fn.name);
        userFunctionNames[fn.owner].push(fn.name);
    }

    // Returns a list of all functions available
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

    // Updates a function property
    function setFunctionProperty(string memory fnName,
        string memory parameter,
        string memory substitute)
        public
    {
        if (!existsFunction(fnName)) revert("Function doesn't exist");
        if(!ifPropertyExists(parameter)) revert("Property doesn't exist");
        bool success = true;
        if(Utils.compareStrings(parameter, "cost")) (success, deployedFunctions[fnName].cost) = Utils.stringToUint(substitute);
        else if(Utils.compareStrings(parameter, "description")) deployedFunctions[fnName].description = substitute;
        else if(Utils.compareStrings(parameter, "prototype")) deployedFunctions[fnName].prototype = substitute;
        if(!success) revert('Invalid parameter');
    }

    // Checks if a given propery name matches one that is part of the function
    function ifPropertyExists(string memory parameter)
        public
        pure
        returns (bool exist)
    {
        bool exist = false;
        string[3] memory parameters = ["cost", "description", "prototype"];
        for(uint i = 0; i<parameters.length && !exist; ++i){
            if(Utils.compareStrings(parameter, parameters[i])) exist = true;
        }
        return exist;
    }

    // Return the function cost set by the user
    function costOfFunction(string memory fnName)
        public
        view
        returns (uint256 cost)
    {
        Function memory fnRequested = getFunctionDetails(fnName);
        return fnRequested.cost;
    }

    // Searches for the position of a function
    function findIndexName(string[] memory array, string memory functionName)
        public
        pure
        returns (uint256 index)
    {
        uint256 index = 0;
        bool find = false;
        for (uint256 i = 0; i<array.length && !find; i++){
            if(Utils.compareStrings(array[i],functionName)){
                index = i;
                find = true;
            }
        }
        if(find) return index;
        revert('Function not found');
    }

    // Removes a function from the storage permanently
    // This should be the only way to remove a function to the storage as it ensures all storage variable are correctly manipulated
    function deleteFunction(address userAddress, string memory functionName)
        public
    {
        // check if function already exists before delete it to the availableFunctionNames
        if (!existsFunction(functionName)) {
            revert("Function doesn't exist");
        }
        uint256 indexUser = findIndexName(userFunctionNames[userAddress], functionName);
        uint256 lengthUser = userFunctionNames[userAddress].length;
        string[] memory userFunctions = userFunctionNames[userAddress];
        userFunctions[indexUser] = userFunctionNames[userAddress][lengthUser-1];
        userFunctionNames[userAddress].pop();

        uint256 indexAvailable = findIndexName(availableFunctionNames, functionName);
        uint256 lengthAvailable = availableFunctionNames.length;
        availableFunctionNames[indexAvailable] = availableFunctionNames[lengthAvailable-1];
        availableFunctionNames.pop();

        delete deployedFunctions[functionName];
    }

    // Creates a Functino structure from the individual properties
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
