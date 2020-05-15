const EtherlessSmart = artifacts.require('./EtherlessSmart.sol');
const Utils = artifacts.require('./Utils.sol');
const FunctionsStorage = artifacts.require('./FunctionsStorage.sol');

module.exports = function (deployer) {
  deployer.deploy(Utils);
  deployer.link(Utils, [FunctionsStorage, EtherlessSmart]);
  deployer.deploy(FunctionsStorage);
  deployer.deploy(EtherlessSmart);
};
