pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

import { Utils } from './utils.sol';
import './FunctionsStorage.sol';

contract EtherlessSmart {

    FunctionsStorage private fnStorage;

    /* EVENTS */
    event RemoteExec(string _name, string _parameters, string _identifier);
    event RemoteResponse(string _response, string _identifier);

    constructor () public {
        fnStorage = new FunctionsStorage();
    }

    function listFunctions()
        public
        view
        returns (string[] memory functionNames)
    {
        return fnStorage.getFunctions();
    }

    function findFunctions(string memory fnToSearch)
        public
        view
        returns (Utils.Function memory)
    {
        return fnStorage.getFunctionDetails(fnToSearch);
    }

    function createFunction(string memory fnName)
        public
    {
        Utils.Function memory fn = Utils.Function({
            name: fnName,
            description: 'temp',
            prototype: 'temp',
            cost: 1,
            owner: msg.sender,
            remoteResource: 'tmp'
        });
        fnStorage.storeFunction(fn);
    }
}
