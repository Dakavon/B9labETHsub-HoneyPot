// const HoneyPot = artifacts.require("HoneyPot");
const Attacker = artifacts.require("Attacker");

module.exports = function (deployer, network, accounts) {
    console.log("  network:", network);

    if(network === "ropsten"){
        const honeyPotAddress = "0x7164292C87269749bc867AEb9159aCA0F296C1dE";
        deployer.deploy(Attacker, honeyPotAddress, {from: accounts[0]});
    }
    else if(network === "develop"){
        deployer.deploy(Attacker, "0x69B3aE172d79360EabC03Bccb54D04876aA1983d", {from: accounts[0]});
        // deployer.deploy(HoneyPot, {from: accounts[0]});
        // .then(() => {
        //     return deployer.deploy(Attacker, HoneyPot.address, {from: accounts[0]});
        // });
    }
};