// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InsuranceLiquidityPool is ERC20 {
    address public owner;

    constructor() ERC20("InsuranceLiquidityToken", "ILT") {
        owner = msg.sender;
    }

    event DepositReceived(address depositor, uint256 amount);
    
    function depositTo(address recipient) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        _mint(recipient, msg.value);  // Mint ILT tokens to the specified recipient
        emit DepositReceived(recipient, msg.value);
    }

   
    
    function withdraw(uint256 amount, address tokenHolder, address payable recipient) public {
    require(balanceOf(tokenHolder) >= amount, "Insufficient balance");
    _burn(tokenHolder, amount);  // Burn ILT tokens from the specified token holder

    recipient.transfer(amount);  // Transfer Ether to the specified recipient
}

    // Additional functions...
}
