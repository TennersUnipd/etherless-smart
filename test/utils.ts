var UtilsLib = artifacts.require("../contracts/Utils.sol");

contract("Utils", () => {
    it("[compareStrings] should be able to compare two strings that are equal", async () => {
        let utils = await UtilsLib.deployed();
        let result = await utils.compareStrings("string", "string");
        assert.equal(result, true, "The two strings are not equal");
    });
    it("[compareStrings] should be able to recognize two strings that are not equal", async () => {
        let utils = await UtilsLib.deployed();
        let result = await utils.compareStrings("string", "soccer");
        assert.equal(result, false, "the two strings are different");
    });
    it("[concat] should be able to concat two strings", async () => {
        let utils = await UtilsLib.deployed();
        let result = await utils.concat("a", "bc");
        assert.equal(result, "abc", "The two strings are not correctly concatenated");
    });

    it("[uint2str] correctly converts an integer to its string form", async () => {
        let utils = await UtilsLib.deployed();
        let result = await utils.uint2str(1);
        assert.equal(result, "1", "The string representation does not match integer value");
    });
});
