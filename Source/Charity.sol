// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "./CGGCtoken.sol";
import "./KINDnft.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IFlashCallback {
    function flashCallback(uint256 amount) external;
}

contract Charity is ReentrancyGuard {
    using SafeERC20 for IERC20;

    CGGCtoken private immutable cggc;
    KINDnft private immutable kind;
    address public immutable cggcAddress;
    address public immutable kindAddress;

    uint256 private tokenID;

    mapping(address => bool) public givenAlms;

    mapping(uint256 => uint256) public donateAmount;

    event Alms(address poorGuy);
    event Donate(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);
    event Flashloan(address borrower, uint256 amount);

    constructor() {
        cggc = new CGGCtoken();
        cggcAddress = address(cggc);

        kind = new KINDnft();
        kindAddress = address(kind);

        tokenID = 0;
    }

    //If you are poor, get some free CGGC tokens:)
    function getAlms() external nonReentrant {
        require(!givenAlms[msg.sender], "Already given.");
        cggc.mint(msg.sender, 10 ether);
        givenAlms[msg.sender] = true;

        emit Alms(msg.sender);
    }

    //Donate to the charity, and you'll get a NFT as a souvenir.
    function donate(uint256 amount) external returns (uint256) {
        require(amount > 0, "Must donate > 0 token.");

        IERC20(cggcAddress).safeTransferFrom(msg.sender, address(this), amount);
        kind.safeMint(msg.sender, tokenID);

        uint256 tokenIDMinted = tokenID;
        donateAmount[tokenIDMinted] += amount;

        tokenID++;

        emit Donate(msg.sender, amount);
        return tokenIDMinted;
    }

    //Please don’t withdraw money QAQ.
    function withdraw(uint256 amount, uint256 _tokenID) external nonReentrant {
        require(amount > 0, "Must withdraw > 0 token.");
        require(msg.sender == IERC721(kindAddress).ownerOf(_tokenID), "Not the NFT owner!");

        uint256 donorBalance = donateAmount[_tokenID];
        require(amount <= donorBalance, "Insufficient fund.");

        IERC20(cggcAddress).safeTransfer(msg.sender, amount);

        donateAmount[_tokenID] -= amount;

        emit Withdraw(msg.sender, amount);
    }

    //You can borrow CGGC token from us, just remember to pay it back.
    function flashLoan(uint256 amount) external nonReentrant {
        require(amount > 0, "Must borrow > 0 token.");

        uint256 balanceBefore = IERC20(cggcAddress).balanceOf(address(this));
        require(balanceBefore >= amount, "Insufficient token.");

        IERC20(cggcAddress).safeTransfer(msg.sender, amount);

        IFlashCallback(msg.sender).flashCallback(amount);

        uint256 balanceAfter = IERC20(cggcAddress).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Token hasn't been returned.");

        emit Flashloan(msg.sender, amount);
    }

    //Meet these conditions to get the flag.
    function isSolved() public view returns (bool) {
        bool condition1 = (IERC20(cggcAddress).balanceOf(address(this)) == 0) ? true : false;
        bool condition2 = tokenID > 0 ? true : false;
        return condition1 && condition2;
    }
}
