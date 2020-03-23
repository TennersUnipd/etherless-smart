pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

library Utils {

    struct Function {
        string name;
        string description;
        string prototype;
        uint256 cost; // in wei
        address payable owner;
        string remoteResource;
    }

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function concat(string memory a, string memory b)
        public
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }
    function uint2str(uint256 _x)
        public
        pure
        returns (string memory _uintAsString)
    {
        uint256 _i = _x;
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