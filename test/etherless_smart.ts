const EtherlessSmart = artifacts.require('EtherlessSmart');

const SERVICE_FEE = 10;

contract('EtherlessSmart', (accounts) => {
  const [bob, alice] = accounts;
  /*  MOCKING (https://github.com/gnosis/mock-contract)
  const MockContract = artifacts.require('MockContract.sol');
  contract('EtherlessSmart', (accounts) => {
  const [bob, alice] = accounts;
  it('esempio test con mocking', async() => {
    const mock = await MockContract.new();
    const smart = await EtherlessSmart.new();

    const getBalance = smart.contract.methods.getBalance().encodeABI();

    await mock.givenMethodReturnUint(getBalance, 5);
    console.log(await smart.getBalance().then((test) => test.words[0])); //print 0
  });
});
  */
  it('should verify the absence of any function on first deploy', async () => {
    const instance = await EtherlessSmart.deployed();
    const listedFunctions = await instance.listFunctions();
    assert.equal(listedFunctions.length, 0, 'There are preloaded functions');
  });
  it('at start, contract balance should be 0', async () => {
    const instance = await EtherlessSmart.new();
    const balance = await instance.getBalance();
    assert.equal(balance, 0, 'Contract initial balance is not 0');
  });
  it('[createFunctions] should add correctly a new function', async () => {
    const functionName = 'test_name_insert_fn';
    const instance = await EtherlessSmart.new();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', 2);
    const storedFunctions = await instance.listFunctions();
    assert.equal(storedFunctions.length, 1, 'Storage is empty');
    const func = storedFunctions[0];
    assert.include(func.name, functionName, 'Stored function name does not match');
    assert.include(func.description, 'description', 'Stored function description does not match');
    assert.include(func.remoteResource, 'remote', 'Stored remote resource description does not match');
    assert.include(func.cost, 2, 'Stored function cost does not match');
    assert.include(func.prototype, 'proto', 'Stored function prototype does not match');
  });

  it('[listFunctions] should correctly return stored functions', async () => {
    const functionName = 'test_name_insert_fn';
    const secondaryFunctionName = `${functionName}_secondary`;
    const instance = await EtherlessSmart.new();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', 2);
    await instance.createFunction(secondaryFunctionName, 'description', 'proto', 'remote', 2);
    const storedFunctions = await instance.listFunctions();
    assert.equal(storedFunctions.length, 2, 'Storage is empty');
    assert.include(storedFunctions[0], functionName, 'Stored function name does not match');
    assert.include(storedFunctions[1], secondaryFunctionName, 'Stored function name does not match');
  });

  it('[findFunction] should correctly find a stored function', async () => {
    const functionName = 'test_name_insert_fn';
    const instance = await EtherlessSmart.new();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', 2);
    try {
      const functionFound = await instance.findFunction(functionName);
      assert.equal(functionFound.name, functionName, 'Functions names not matching');
      assert.equal(functionFound.description, 'description', 'Functions descriptions not matching');
      assert.equal(functionFound.prototype, 'proto', 'Functions proto not matching');
      assert.equal(functionFound.remoteResource, 'remote', 'Functions remote resource not matching');
      assert.equal(functionFound.cost, 2 + Number(SERVICE_FEE), 'Functions cost not matching');
    } catch {
      assert.fail('Function not found even if it was created');
    }
  });

  it('[findFunction] should correctly handle a not found function', async () => {
    const functionName = 'test_name_not_found_fn';
    const instance = await EtherlessSmart.deployed();
    try {
      const functionFound = await instance.findFunction(functionName);
      assert.fail('Function does not exist');
    } catch (e) {
      assert.isOk(true, 'Function was found');
    }
  });

  it('[runFunction] should be able to run a stored function', async () => {
    const functionName = 'test_name_run_fn';
    const instance = await EtherlessSmart.deployed();
    try {
      await instance.createFunction(functionName, 'description', 'proto', 'remote', 2);
    } catch {
      assert.fail('Unable to create the function');
      return;
    }
    try {
      const cost = await instance.costOfFunction(functionName);
      await instance.runFunction(functionName, '{}', 'identifier', { value: cost });
    } catch {
      assert.fail('Unable to run function');
    }
  });

  it('[costOfFunction] should get correct cost of function', async () => {
    const functionName = 'test_name_cost_fn';
    const cost = 2;
    const instance = await EtherlessSmart.new();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', cost);
    try {
      const retrievedCost = await instance.costOfFunction(functionName);
      assert.equal(retrievedCost, cost + SERVICE_FEE, 'Functions have different costs');
    } catch {
      assert.fail('Function not found even if it was created');
    }
  });

  it('[runFunction] contract balance increment should meet expectancy', async () => {
    const functionName = 'test_name_balance_fn';
    const estimatedContractIncrement = Number(SERVICE_FEE);
    const instance = await EtherlessSmart.deployed();
    const initialBalance = Number(await instance.getBalance());
    try {
      await instance.createFunction(functionName, 'description', 'proto', 'remote', 2);
    } catch {
      assert.fail('Unable to create the function');
      return;
    }
    try {
      const cost = await instance.costOfFunction(functionName);
      await instance.runFunction(functionName, '{}', 'identifier', { value: cost });
    } catch {
      assert.fail('Unable to run function');
      return;
    }
    const finalBalance = Number(await instance.getBalance());
    assert.equal(finalBalance, estimatedContractIncrement + initialBalance, 'Contract balance does not meet expectancy');
  });

  it('[runFunction] run of function should correctly transfer money from caller to owner', async () => {
    const functionName = 'test_name_balance_transfer_owner_fn';
    const instance = await EtherlessSmart.deployed();
    const cost = 100000;
    const aliceInitialBalance = await web3.eth.getBalance(alice); // caller
    try {
      await instance.createFunction(functionName, 'description', 'proto', 'remote', cost, { from: bob });
    } catch {
      assert.fail('Unable to create the function');
      return;
    }
    const bobInitialBalance = await web3.eth.getBalance(bob); // owner
    try {
      const cost = await instance.costOfFunction(functionName);
      await instance.runFunction(functionName, '{}', 'identifier', { value: cost, from: alice });
    } catch {
      assert.fail('Unable to run function');
      return;
    }
    const bobFinalBalance = await web3.eth.getBalance(bob);
    const aliceFinalBalance = await web3.eth.getBalance(alice);
    assert(bobFinalBalance > bobInitialBalance + cost, 'Bob did not receive all the money he deserves');
    assert(aliceFinalBalance < aliceInitialBalance - cost, 'Alice did not pay');
  });


  it('[setFunctionProperty] should modify a parameter string of the function', async () => {
    const functionName = 'test_set_function_property_string';
    const param = 'description';
    const subst = 'bho';
    const instance = await EtherlessSmart.deployed();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', 20);
    try {
      await instance.setFunctionProperty(functionName, param, subst);
      const fn2 = await instance.findFunction(functionName);
      assert.equal(fn2.description, subst, 'Function description unchanged');
    } catch {
      assert.fail('Errore interno di setFunctionProperty');
    }
  });

  it('[setFunctionProperty] should modify a parameter uint of the function', async () => {
    const functionName = 'test_set_function_property_uint';
    const param = 'cost';
    const subst = '25';
    const subst2 = 25;
    const instance = await EtherlessSmart.deployed();
    await instance.createFunction(functionName, 'description', 'proto', 'remote', 20);
    try {
      await instance.setFunctionProperty(functionName, param, subst);
      const fn2 = await instance.findFunction(functionName);
      assert.equal(fn2.cost, subst2 + 10, 'Function cost unchanged');
    } catch {
      assert.fail('Errore interno di setFunctionProperty');
    }
  });
  it('[deleteFunctions] should delete correctly a function', async () => {
    const functionName = 'test_name_insert_fn';
    const instance = await EtherlessSmart.deployed();
    await instance.createFunction(functionName, 'ciao', 'test', 'test', 10);
    await instance.deleteFunction(functionName);
    try {
      const bool = await instance.findFunction(functionName);
      assert.fail('Function not deleted');
    } catch {
      assert.ok(true);
    }
  });

  it('[getArn] should return the ARN of a function', async () => {
    const functionName = 'test_name_get_arn';
    const instance = await EtherlessSmart.deployed();
    await instance.createFunction(functionName, 'ciao', 'test', 'test', 10);
    const arn = await instance.getArn(functionName);
    const fn = await instance.findFunction(functionName);
    assert.equal(arn, fn.remoteResource, 'Different arn');
  });
});
