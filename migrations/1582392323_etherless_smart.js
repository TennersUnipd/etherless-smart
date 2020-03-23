var EtherlessSmart = artifacts.require("./EtherlessSmart.sol");
var UtilsLib = artifacts.require("./utils.sol");
var FNStorage = artifacts.require("./FunctionsStorage.sol");

module.exports = function (deployer) {
    deployer.deploy(UtilsLib);
    deployer.link(UtilsLib, [FNStorage, EtherlessSmart]);
    deployer.deploy(FNStorage);
    deployer.deploy(EtherlessSmart);
};
