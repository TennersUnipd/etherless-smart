pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;

library Utils {

    // Compares two strings and returns a boolean
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // Returns a merged string of the 2 given
    function concat(string memory a, string memory b)
        public
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    // Returns a string rapresentation of the given integer
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

    // Return an integer rapresentation of the given string
    function stringToUint(string memory s)
        public
        pure
        returns (bool success, uint result)
    {
        bytes memory b = bytes(s);
        uint result = 0;
        success = false;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= bytes1(uint8(48)) && b[i] <= bytes1(uint8(57))) {
                result = result * 10 + (uint8(b[i]) - 48);
                success = true;
            } else {
                result = 0;
                success = false;
                break;
            }
        }
        return (success,result);
    }
}