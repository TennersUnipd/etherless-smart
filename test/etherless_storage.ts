var FunctionsStorage = artifacts.require("FunctionsStorage");

contract("FunctionsStorage", (accounts) => {
    const [bob] = accounts;

    it("at start, storage should be empty", async () => {
        let storage = await FunctionsStorage.deployed();
        let functions = await storage.getFunctions();
        assert.equal(functions.length, 0, "Storage is not empty");
    });

    it("should correctly add a function", async () => {
        let storage = await FunctionsStorage.deployed();
        const functionName = "test_sdd_fn";
        const fn = await storage.buildFunction(functionName, "description", "proto", 2, "remote", bob);
        await storage.storeFunction(fn);
        const storedFunctions = await storage.getFunctions();
        assert.equal(storedFunctions.length, 1, "Storage is empty");
        assert.equal(storedFunctions[0].name, functionName, "Stored function name does not match");
        const exists = await storage.existsFunction(functionName);
        assert.equal(exists, true, "Function does not exist");
    });

    it("[getFunctions] should correctly retrieve a function", async () => {
        let storage = await FunctionsStorage.new();
        const functionName = "test_retrieve_fn";
        const fn = await storage.buildFunction(functionName, "description", "proto", 2, "remote", bob);
        await storage.storeFunction(fn);
        const storedFunctions = await storage.getFunctions();
        assert.equal(storedFunctions.length, 1, "Storage is empty");
        const retrieved = storedFunctions[0];
        assert.equal(retrieved.name, functionName, "Stored function name does not match");
        assert.equal(retrieved.description, "description", "Stored function description does not match");
        assert.equal(retrieved.prototype, "proto", "Stored function prototype does not match");
        assert.equal(retrieved.cost, 2, "Stored function cost does not match");
        assert.equal(retrieved.remoteResource, "remote", "Stored function remoteResource does not match");
    });

    it("should be unable to add function that already exists", async () => {
        const fnName = "test_23";

        let storage = await FunctionsStorage.deployed();
        const fn = await storage.buildFunction(fnName, "description", "proto", 2, "remote", bob);
        await storage.storeFunction(fn);
        try {
            await storage.storeFunction(fn);
            assert.fail("Function added successufly even if it already exists");
        }
        catch{
            assert.isOk(true);
        }
    });

    it("should recognize function that alrady exists", async () => {
        const fnName = "exists_test";

        let storage = await FunctionsStorage.deployed();
        const fn = await storage.buildFunction(fnName, "description", "proto", 2, "remote", bob);
        await storage.storeFunction(fn);
        const exists = await storage.existsFunction(fnName);
        assert.equal(exists, true, "Function does not exist");
    });

    it("should correctly find a stored function", async () => {
        const functionName = "test_name_exists_in_storage";
        let instance = await FunctionsStorage.deployed();

        const fn = await instance.buildFunction(functionName, "description", "proto", 2, "remote", bob);
        await instance.storeFunction(fn);
        try {
            const functionFound = await instance.getFunctionDetails(functionName);
            assert.equal(functionFound.name, functionName, "Functions names not matching");
            assert.equal(functionFound.description, "description", "Functions descrptions not matching");
            assert.equal(functionFound.prototype, "proto", "Functions proto not matching");
            assert.equal(functionFound.remoteResource, "remote", "Functions remote resource not matching");
            assert.equal(functionFound.cost, 2, "Functions cost not matching");
        } catch {
            assert.fail("Function not found even if it was created");
        }        
    });

    it("[costOfFunction] should get correct cost of function", async () => {
        const functionName = "test_name_cost_fn_in_storage";
        const cost = 3;
        let instance = await FunctionsStorage.deployed();
        const fn = await instance.buildFunction(functionName, "description", "proto", cost, "remote", bob);
        await instance.storeFunction(fn);
        try {
            const retrievedCost = await instance.costOfFunction(functionName);
            assert.equal(retrievedCost, cost, "Functions have different costs");
        } catch {
            assert.fail("Function not found even if it was created");
        }        
    });

});
