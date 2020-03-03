var EtherlessSmart = artifacts.require("./EtherlessSmart.sol");

module.exports = function (deployer) {
    deployer.deploy(EtherlessSmart);
};
