var EtherlessSmart = artifacts.require("./EtherlessSmart.sol");
var Utils = artifacts.require("./Utils.sol");
var FunctionsStorage = artifacts.require("./FunctionsStorage.sol");

module.exports = function (deployer) {
    deployer.deploy(Utils);
    deployer.link(Utils, [FunctionsStorage, EtherlessSmart]);
    deployer.deploy(FunctionsStorage);
    deployer.deploy(EtherlessSmart);
};
