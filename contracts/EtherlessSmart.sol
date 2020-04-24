pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './Utils.sol';
import './FunctionsStorage.sol';

contract EtherlessSmart {

    FunctionsStorage private fnStorage;

    uint256 private balance = 0;
    uint256 private serviceCostPerFunctionExecution = 10;

    /* EVENTS */
    event RemoteExec(string _name, string _parameters, string _identifier);
    event RemoteResponse(string _response, string _identifier);

    constructor () public {
        fnStorage = new FunctionsStorage();
    }

    function getBalance()
        public view
        returns (uint256) {
            return balance;
    }

    function listFunctions()
        public
        view
        returns (FunctionsStorage.Function[] memory functionNames)
    {
        return fnStorage.getFunctions();
    }

    function findFunction(string memory fnToSearch)
        public
        view
        returns (FunctionsStorage.Function memory)
    {
        FunctionsStorage.Function memory fn = fnStorage.getFunctionDetails(fnToSearch);
        fn.cost = fn.cost + serviceCostPerFunctionExecution;
        return fn;
    }

    function createFunction(string memory fnName,
        string memory description,
        string memory prototype,
        string memory remoteResource,
        uint256 cost)
        public
    {
        if (fnStorage.existsFunction(fnName)){
            revert("Function not found");
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

     function runFunction(string memory fnName, string memory paramers, string memory identifier)
        public
        payable
    {
        require(
            bytes(paramers).length > 0,
            "Invalid paramers serialization (length = 0)"
        ); // length conversion valid only for some encodings
        // check if function with given name exists

        // get function data
        FunctionsStorage.Function memory fnRequested = fnStorage.getFunctionDetails(fnName);

        // check if correct ether amount sent by caller
        uint256 fnCostToRun = costOfFunction(fnName);
        uint256 amountSentByCaller = msg.value; // rappresenta il quantitativo di soldi inviati dall'utente a questa funzione
        require(
            amountSentByCaller == fnCostToRun,
            Utils.concat(
                "Incorrect transaction amount sent by caller ",
                Utils.uint2str(amountSentByCaller)
            )
        );
        balance += amountSentByCaller;
        moveCurrencies(fnRequested.owner, fnRequested.cost);
        

        emit RemoteExec(fnRequested.remoteResource, paramers, identifier);
    }

    function deleteFunction(string memory nameFunction)
        public
    {
        FunctionsStorage.Function memory fn = findFunction(nameFunction);
        if(msg.sender != fn.owner){
            revert('You are not the owner of the function!');
        }
        fnStorage.deleteFunction(fn.owner, nameFunction);
    }

    function getARN(string memory fnName)
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

    function moveCurrencies(address payable receiver, uint256 amount)
        private
    {
        balance -= amount;
         receiver.transfer(amount);
    }

    function sendResponse(string memory result, string memory identifier) public {
        emit RemoteResponse(result, identifier);
    }

    function costOfFunction(string memory fnName)
        public
        view
        returns (uint256 cost)
    {
        return fnStorage.costOfFunction(fnName) + serviceCostPerFunctionExecution;
    }
}


