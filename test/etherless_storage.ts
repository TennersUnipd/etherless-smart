const FunctionsStorage = artifacts.require('FunctionsStorage');

contract('FunctionsStorage', (accounts) => {
  const [bob] = accounts;

  it('at start, storage should be empty', async () => {
    let storage;
    let functions;
    try {
      storage = await FunctionsStorage.deployed();
      functions = await storage.getFunctions();
    } catch (Exception) {
      assert.fail();
    }
    assert.equal(functions.length, 0, 'Storage is not empty');
  });

  it('should correctly add a function', async () => {
    const storage = await FunctionsStorage.deployed();
    const functionName = 'test_sdd_fn';
    const fn = await storage.buildFunction(functionName, 'description', 'proto', 2, 'remote', bob);
    await storage.storeFunction(fn);
    const storedFunctions = await storage.getFunctions();
    assert.equal(storedFunctions.length, 1, 'Storage is empty');
    assert.equal(storedFunctions[0].name, functionName, 'Stored function name does not match');
    const exists = await storage.existsFunction(functionName);
    assert.equal(exists, true, 'Function does not exist');
  });

  it('[getFunctions] should correctly retrieve a function', async () => {
    const storage = await FunctionsStorage.new();
    const functionName = 'test_retrieve_fn';
    const fn = await storage.buildFunction(functionName, 'description', 'proto', 2, 'remote', bob);
    await storage.storeFunction(fn);
    const storedFunctions = await storage.getFunctions();
    assert.equal(storedFunctions.length, 1, 'Storage is empty');
    const retrieved = storedFunctions[0];
    assert.equal(retrieved.name, functionName, 'Stored function name does not match');
    assert.equal(retrieved.description, 'description', 'Stored function description does not match');
    assert.equal(retrieved.prototype, 'proto', 'Stored function prototype does not match');
    assert.equal(retrieved.cost, 2, 'Stored function cost does not match');
    assert.equal(retrieved.remoteResource, 'remote', 'Stored function remoteResource does not match');
  });

  it('should be unable to add function that already exists', async () => {
    const fnName = 'test_23';

    const storage = await FunctionsStorage.deployed();
    const fn = await storage.buildFunction(fnName, 'description', 'proto', 2, 'remote', bob);
    await storage.storeFunction(fn);
    try {
      await storage.storeFunction(fn);
      assert.fail('Function added successfully even if it already exists');
    } catch {
      assert.isOk(true);
    }
  });

  it('should recognize function that already exists', async () => {
    const fnName = 'exists_test';

    const storage = await FunctionsStorage.deployed();
    const fn = await storage.buildFunction(fnName, 'description', 'proto', 2, 'remote', bob);
    await storage.storeFunction(fn);
    const exists = await storage.existsFunction(fnName);
    assert.equal(exists, true, 'Function does not exist');
  });

  it('should correctly find a stored function', async () => {
    const functionName = 'test_name_exists_in_storage';
    const instance = await FunctionsStorage.deployed();

    const fn = await instance.buildFunction(functionName, 'description', 'proto', 2, 'remote', bob);
    await instance.storeFunction(fn);
    try {
      const functionFound = await instance.getFunctionDetails(functionName);
      assert.equal(functionFound.name, functionName, 'Functions names not matching');
      assert.equal(functionFound.description, 'description', 'Functions descriptions not matching');
      assert.equal(functionFound.prototype, 'proto', 'Functions proto not matching');
      assert.equal(functionFound.remoteResource, 'remote', 'Functions remote resource not matching');
      assert.equal(functionFound.cost, 2, 'Functions cost not matching');
    } catch {
      assert.fail('Function not found even if it was created');
    }
  });

  it('[costOfFunction] should get correct cost of function', async () => {
    const functionName = 'test_name_cost_fn_in_storage';
    const cost = 3;
    const instance = await FunctionsStorage.deployed();
    const fn = await instance.buildFunction(functionName, 'description', 'proto', cost, 'remote', bob);
    await instance.storeFunction(fn);
    try {
      const retrievedCost = await instance.costOfFunction(functionName);
      assert.equal(retrievedCost, cost, 'Functions have different costs');
    } catch {
      assert.fail('Function not found even if it was created');
    }
  });


  it('[setFunctionProperty] should modify a parameter string of the function', async () => {
    const functionName = 'test_set_function_property_string';
    const param = 'description';
    const subst = 'bho';
    const instance = await FunctionsStorage.deployed();
    const fn = await instance.buildFunction(functionName, 'description', 'proto', '20', 'remote', bob);
    await instance.storeFunction(fn);
    try {
      await instance.setFunctionProperty(functionName, param, subst);
      const fn2 = await instance.getFunctionDetails(functionName);
      assert.equal(fn2.description, subst, 'Function description unchanged');
    } catch {
      assert.fail('Errore interno di setFunctionProperty');
    }
  });

  it('[setFunctionProperty] should modify a parameter uint256 of the function', async () => {
    const functionName = 'test_set_function_property_uint';
    const param = 'cost';
    const subst = '15';
    const subst2 = 15;
    const instance = await FunctionsStorage.deployed();
    const fn = await instance.buildFunction(functionName, 'description', 'proto', '20', 'remote', bob);
    await instance.storeFunction(fn);
    try {
      await instance.setFunctionProperty(functionName, param, subst);
      const fn2 = await instance.getFunctionDetails(functionName);
      assert.equal(fn2.cost, subst2, 'Function cost unchanged');
    } catch {
      assert.fail('Errore interno di setFunctionProperty');
    }
  });
  it('[deleteFunctions] should delete correctly a function', async () => {
    const functionName = 'test_name_insert_fn';
    const instance = await FunctionsStorage.deployed();
    const fn = await instance.buildFunction(functionName, 'ciao', 'test', 10, 'remote', bob);
    await instance.storeFunction(fn);
    const array1 = await instance.getFunctions();
    try {
      await instance.deleteFunction(bob, functionName);
      const array2 = await instance.getFunctions();
      const index = array2.indexOf(fn);
      assert.equal(index, -1, 'Function still exists');
    } catch {
      assert.fail('Function not found even if it was created');
    }
  });
});
