const UtilsLib = artifacts.require('../contracts/Utils.sol');

contract('Utils', () => {
  it('[compareStrings] should be able to compare two strings that are equal', async () => {
    let utils;
    let result;
    try {
      utils = await UtilsLib.deployed();
      result = await utils.compareStrings('string', 'string');
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(result, true, 'The two strings are not equal');
  });
  it('[compareStrings] should be able to recognize two strings that are not equal', async () => {
    let utils;
    let result;
    try {
      utils = await UtilsLib.deployed();
      result = await utils.compareStrings('string', 'soccer');
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(result, false, 'the two strings are different');
  });
  it('[concat] should be able to concat two strings', async () => {
    let utils;
    let result;
    try {
      utils = await UtilsLib.deployed();
      result = await utils.concat('a', 'bc');
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(result, 'abc', 'The two strings are not correctly concatenated');
  });
  it('[uint2str] correctly converts an integer to its string form', async () => {
    let utils;
    let result;
    try {
      utils = await UtilsLib.deployed();
      result = await utils.uint2str(1);
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(result, '1', 'The string representation does not match integer value');
  });
  it('[stringToUint] correctly converts a string to its integer form', async () => {
    let utils;
    let result;
    try {
      utils = await UtilsLib.deployed();
      result = await utils.stringToUint('1');
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(result[1], 1, 'The uint representation does not match string value');
  });
});
