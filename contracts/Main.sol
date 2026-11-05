// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { Ownable } from "./Ownable.sol";
import { Pausable } from "./Pausable.sol";
import "./Users.sol";

contract Main is Ownable, Pausable {
    uint256 constant MAX_BATCH = 200;
    using Users for Users.User[];

    mapping(address => uint256) private _balances;

    event Deposited(address indexed user, uint256 amount);
    event WithdrawnToOwner(address indexed user, uint256 amount);
    event WithdrawnToUser(address indexed winner, uint256 amount);

    error DepositInsufficientValue(string message);
    error WithdrawnInsufficientValue(string message);

    constructor() Ownable(_msgSender()) {}

    receive() external payable {}
    fallback() external payable {}

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function _getContractBalance() internal view whenNotPaused returns (uint256){
        return address(this).balance;
    }

    function balanceOf(address account) external view whenNotPaused returns (uint256){
        return _balances[account];
    }

    function deposit() external payable whenNotPaused {
        if(msg.value <= 0) {
            revert DepositInsufficientValue("Less than accepted");
        }

        _balances[_msgSender()] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdrawnToOwner(address to, uint256 amount) external onlyOwner whenNotPaused {
        if(amount <= 0){
            revert DepositInsufficientValue("Less than accepted");
        }
        if(amount > _getContractBalance()){
            revert DepositInsufficientValue("Insufficient contract balance");
        }

        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
        emit WithdrawnToOwner(to, amount);
    }

    function withdrawnToUser(Users.User calldata user) external whenNotPaused {
        if(user.amount <= 0){
            revert WithdrawnInsufficientValue("Less than accepted");
        }
        if(user.amount > _balances[user.userAddress]){
            revert WithdrawnInsufficientValue("Insufficient user balance");
        }
        if(user.amount > _getContractBalance()){
            revert WithdrawnInsufficientValue("Insufficient contract balance");
        }

        (bool success, ) = user.userAddress.call{value: user.amount}("");
        require(success, "Transfer failed");
        _balances[user.userAddress] -= user.amount;
        emit WithdrawnToUser(user.userAddress, user.amount);
    }

    function addWinnersBalance(Users.User[] calldata banch) external onlyOwner whenNotPaused {
        require(banch.length <= MAX_BATCH, "Too many");
        for(uint i = 0; i < banch.length; i++){
            if(banch[i].userAddress != address(0) && banch[i].amount > 0){
                _balances[banch[i].userAddress] += banch[i].amount;
            }
        }
    }
}