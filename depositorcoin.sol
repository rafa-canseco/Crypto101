//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import {ERC20} from "./erc20.sol";

contract DepositorCoin is ERC20{
    address public owner;
    constructor() ERC20("DepositorCoin", "DPC"){
        owner = msg.sender;
    }

function mint (address to, uint256 amount) external{
    require(msg.sender == owner,"DPC: ONLY OWNER CAN MINT");
    _mint(to,amount);
}

function burn (address from, uint256 amount) external{
    require(msg.sender == owner,"DPC: ONLY OWNER CAN burn");
    _burn(from,amount);
}



}