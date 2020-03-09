const EtherlessSmart = artifacts.require('EtherlessSmart');

contract('EtherlessSmart', (accounts) => {
  const [bob] = accounts;
  it('should verify the absence of any function on first deploy', async () => {
    const instance = await EtherlessSmart.deployed();
    const listedFunctions = await instance.listFunctions.call();
    assert.equal(listedFunctions.length, 0, 'The deployment is not correct');
  });
  it('should verify that the insertion of one function is working', async () => {
    const instance = await EtherlessSmart.deployed();
    const address = bob;
    const fnName = 'test';
    const description = 'This is a test function';
    const prototype = '(name)';
    const remote = '';
    const cost = 2;
    // TODO find a more compact way to send this informations with less arguments
    await instance.createFunction(fnName, description, prototype, remote, cost);
    const listedFunctions = await instance.listFunctions.call();
    const getCost = Number(await instance.costOfFunction(fnName));
    assert.equal(listedFunctions.length, 1, 'The deployment is not correct');
    assert.equal(getCost, cost, 'The cost doesnt match');
  });
});
