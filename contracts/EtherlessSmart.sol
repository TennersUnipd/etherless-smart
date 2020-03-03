pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

contract EtherlessSmart {
    constructor() public {}
    /* DATA */
    struct Function {
        string name;
        string description;
        string prototype;
        uint256 cost; // in wei
        address payable owner;
        string remoteResource;
    }

    uint256 constant ServiceFee = 1; // can be declared later as percentage
    uint256 balance = 0;

    mapping(string => Function) private deployedFunctions; // <nome funzione> -> <Function>
    string[] public availableFunctionNames;

    mapping(address => string[]) private userFunctionNames;

    /* EVENTS */
    event RemoteExec(string _name, string _parameters, string _identifier);
    event RemoteResponse(string _response, string _identifier);

    // require, assert, revert

    /* PUBLIC INTERFACES */
    function execFunctionRequest(string memory fnName, string memory paramers, string memory identifier)
        public
        payable
    {
        require(
            bytes(paramers).length > 0,
            "Invalid paramers serialization (length = 0)"
        ); // length conversion valid only for some encodings
        // check if function with given name exists
        if (!existsFunction(fnName)) {
            revert("Function not found");
        }
        // get function data
        Function memory fnRequested = deployedFunctions[fnName];

        // check if correct ether amount sent by caller
        uint256 fnCostToRun = costOfFunction(fnRequested);
        uint256 amountSentByCaller = msg.value; // rappresenta il quantitativo di soldi inviati dall'utente a questa funzione
        require(
            amountSentByCaller == fnCostToRun,
            concat(
                "Incorrect transaction amount sent by caller ",
                uint2str(amountSentByCaller)
            )
        );
        balance += amountSentByCaller;
        if (!moveCurrencies(fnRequested.owner, fnCostToRun)) {
            revert("Unable to process transaction");
        }

        // pretend to be calling function from aws
        execRemoteRequest(fnRequested.remoteResource, paramers, identifier);
        // add timer or something that will trigger "Unable to call remote execution"
        /*bool remoteTriggerSuccess = true;
        if (!remoteTriggerSuccess) {
            revert("Unable to call remote resource execution");   
        }*/
    }

    function listFunctions()
        public
        view
        returns (string[] memory functionNames)
    {
        return availableFunctionNames;
    }

    function createFunction(
        string memory fnName,
        string memory description,
        string memory prototype,
        string memory remoteResource,
        uint256 cost
    ) public {
        // TODO: add paramers checks
        // require(cost <= 0, "Invalid cost, cost must be greater than 0");

        Function memory newFn = Function({
            name: fnName,
            description: description,
            prototype: prototype,
            cost: cost,
            owner: msg.sender,
            remoteResource: remoteResource
        });
        storeFunction(newFn);
    }

    function costOfFunction(string memory fnName)
        public
        view
        returns (uint256 cost)
    {
        if (!existsFunction(fnName)) {
            revert("Function not found");
        }
        Function memory fnRequested = deployedFunctions[fnName];
        return costOfFunction(fnRequested);
    }

    // send event that will trigger remote execution
    function execRemoteRequest(string memory remoteName, string memory paramers, string memory identifier)
        private
    {
        emit RemoteExec(remoteName, paramers, identifier);
    }

    // remove execution will return result via this call
    // result will be emitted to eth-cli
    function execRemoteResponse(string memory result, string memory identifier) public {
        emit RemoteResponse(result, identifier);
    }

    /* PRIVATE FUNCTIONS */
    function costOfFunction(Function memory fn)
        private
        view
        returns (uint256 cost)
    {
        return fn.cost;
    }

    // check if functino with given name exists
    function existsFunction(string memory named) private view returns (bool) {
        bool found = false;
        for (uint256 i = 0; i < availableFunctionNames.length; i++) {
            found = (compareStrings(availableFunctionNames[i], named));
            if (found) break;
        }
        return found;
    }

    function storeFunction(Function memory fn) private {
        // check if function already exists before adding it to the availableFunctionNames
        if (existsFunction(fn.name)) {
            revert("Function already exits and cannot be created");
        }
        // check if another funcion is already linked to remote resource
        deployedFunctions[fn.name] = fn;
        availableFunctionNames.push(fn.name);
        userFunctionNames[fn.owner].push(fn.name);
    }

    // calculates how much profit for the function creator based on how much Ethreless keeps for itself
    function profitPerFunctionRun(uint256 fnCost)
        private
        view
        returns (uint256 profit)
    {
        return fnCost - ServiceFee;
    }

    // Eth exchange
    function moveCurrencies(address payable receiver, uint256 amount)
        private
        returns (bool success)
    {
        balance -= amount;
        return receiver.send(amount);
    }

    /* UTILITIES */
    function compareStrings(string memory a, string memory b)
        private
        view
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function concat(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
