pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

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
}
