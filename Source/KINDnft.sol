// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KINDnft is ERC721, Ownable {
    constructor() ERC721("kindPerson", "KIND") Ownable(msg.sender) {}

    function safeMint(address to, uint256 tokenID) public onlyOwner {
        _safeMint(to, tokenID);
    }
}
