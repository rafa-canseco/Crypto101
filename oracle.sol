//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract oracle{
    address public owner;
    uint256 private price;

    constructor(){
        owner = msg.sender;

    }

    function getPrice() external view returns (uint256){
        return price;
    }

    function setPrice(uint256 newPrice) external{
        require(msg.sender == owner, "oracle: only owner");
        price = newPrice;
    }
}