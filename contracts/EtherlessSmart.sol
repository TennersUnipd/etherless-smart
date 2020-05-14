pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './Utils.sol';
import './FunctionsStorage.sol';

// Main contract definition which exposes functionalities to the other service components
contract EtherlessSmart {

    // The contract instance used for storing service data (functions, etc...)
    FunctionsStorage private fnStorage;

    // contract balance internal reference
    uint256 private balance = 0;

    // fixed cost per function run request
    uint256 private serviceCostPerFunctionExecution = 10;

    /* EVENTS */
    // An event that triggers the server component and requests a remote function execution
    event RemoteExec(string _name, string _parameters, string _identifier);
    // An event that triggers the client component and delivers the remote function execution result
    event RemoteResponse(string _response, string _identifier);
    /* END EVENTS */

    constructor () public {
        // TODO: this should not be here as it's handled by Truffle
        fnStorage = new FunctionsStorage();
    }

    // Returns the contract balance
    function getBalance()
        public view
        returns (uint256) {
            return balance;
    }

    // Returns the list of functions from the storage
    function listFunctions()
        public
        view
        returns (FunctionsStorage.Function[] memory functionNames)
    {
        return fnStorage.getFunctions();
    }

    // Returns function data specificcaly for the given function name
    // If the function name does not exists a function not found error will be triggered
    function findFunction(string memory fnToSearch)
        public
        view
        returns (FunctionsStorage.Function memory)
    {
        FunctionsStorage.Function memory fn = fnStorage.getFunctionDetails(fnToSearch);
        // Total cost displayed to the user: function owner-defined cost + service fee per run request
        fn.cost = fn.cost + serviceCostPerFunctionExecution;
        return fn;
    }

    // Creates and stores a new function with the given properties for the network user
    function createFunction(string memory fnName,
        string memory description,
        string memory prototype,
        string memory remoteResource,
        uint256 cost)
        public
    {
        // Checks if the function already exists
        if (fnStorage.existsFunction(fnName)){
            revert("Function already exists");
        }
        FunctionsStorage.Function memory fn = FunctionsStorage.Function({
            name: fnName,
            description: description,
            prototype: prototype,
            cost: cost,
            owner: msg.sender,
            remoteResource: remoteResource
        });
        fnStorage.storeFunction(fn);
    }

    // Starts the remote function execution process
    // Identifiers are strings that identify the execution request
     function runFunction(string memory fnName, string memory paramers, string memory identifier)
        public
        payable
    {
        require(
            bytes(paramers).length > 0,
            "Invalid paramers serialization (length = 0)"
        ); // length conversion valid only for some encodings

        // get function data
        FunctionsStorage.Function memory fnRequested = fnStorage.getFunctionDetails(fnName);

        // check if correct ether amount sent by caller
        uint256 fnCostToRun = costOfFunction(fnName);
        uint256 amountSentByCaller = msg.value; // msg.value is the amount of ether send by the user to the contract with this method call
        require(
            amountSentByCaller == fnCostToRun,
            Utils.concat(
                "Incorrect transaction amount sent by caller ",
                Utils.uint2str(amountSentByCaller)
            )
        );
        balance += amountSentByCaller;
        // move function cost amount to the owner of the function
        moveCurrencies(fnRequested.owner, fnRequested.cost);

        // emits the execution request event
        // the server component will pick this and run the funciton
        emit RemoteExec(fnRequested.remoteResource, paramers, identifier);
    }

    // Updates a given property of a function to a new value
    // Only function owners can change properties
    function setFunctionProperty(string memory fnName,
        string memory parameter,
        string memory substitute)
        public
    {
        FunctionsStorage.Function memory fn = findFunction(fnName);
        if(msg.sender != fn.owner){
            revert('You are not the owner of the function!');
        }
        fnStorage.setFunctionProperty(fnName, parameter, substitute);
    }

    // Deletes a function from the storage
    // Only function owners can delete their funcitons
    function deleteFunction(string memory nameFunction)
        public
    {
        FunctionsStorage.Function memory fn = findFunction(nameFunction);
        if(msg.sender != fn.owner){
            revert('You are not the owner of the function!');
        }
        fnStorage.deleteFunction(fn.owner, nameFunction);
    }

    // Return the remote resource identifier
    // Only function owners can request the resource identifier for their functions
    function getArn(string memory fnName)
        public
        view
        returns (string memory arn)
    {
        FunctionsStorage.Function memory fn = findFunction(fnName);
        if(msg.sender != fn.owner){
            revert('You are not the owner of the function!');
        }
        return fn.remoteResource;
        
    }

    // Transfers Ether from the contract to a given user
    function moveCurrencies(address payable receiver, uint256 amount)
        private
    {
        balance -= amount;
         receiver.transfer(amount);
    }

    // Sends an execution result to the client component
    // Identifiers are strings that identify the execution request
    function sendResponse(string memory result, string memory identifier) public {
        emit RemoteResponse(result, identifier);
    }

    // Returns the cost for running a function for the end user
    function costOfFunction(string memory fnName)
        public
        view
        returns (uint256 cost)
    {
        return fnStorage.costOfFunction(fnName) + serviceCostPerFunctionExecution;
    }
}


