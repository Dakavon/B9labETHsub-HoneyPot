// SPDX-License-Identifier: Unlicense

//B9lab ETH-SUB Ethereum Developer Subscription Course
//>>> Owned <<<
//
//Last update: 19.12.2020

pragma solidity 0.6.12;

/**
 * @title Owned
 *  Owner administration
 */
contract Owned{
    //Variable declaration
    address private owner;

    //Events
    event LogOwnerChanged(address indexed oldOwner, address indexed newOwner);
    event LogOwnershipRenounced(address indexed owner);

    //Modifier
    modifier onlyOwner{
        require(msg.sender == owner, "Owned: Caller is not the owner");
        _;
    }

    //Initial function
    constructor() public{
        owner = msg.sender;
    }

    //Retrieve owner address
    function getOwner() public view returns(address ownersAddress){
        return owner;
    }

    //Change owner
    function changeOwner(address newOwner) public onlyOwner returns(bool success){
        require(newOwner != address(0x0), "Owned: Ownership is not transferable to 0x0");
        require(newOwner != owner, "Owned: Ownership is not self-transferable");

        owner = newOwner;

        emit LogOwnerChanged(msg.sender, newOwner);
        return true;
    }
}