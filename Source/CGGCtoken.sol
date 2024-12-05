// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CGGCtoken is ERC20, Ownable {
    constructor() ERC20("CGGCtoken", "CGGC") Ownable(msg.sender) {
        _mint(msg.sender, 1000 ether);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
