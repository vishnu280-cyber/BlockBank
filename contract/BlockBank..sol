
    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BlockBank
 * @dev A decentralized banking smart contract for deposits, withdrawals, and transfers
 */
contract Project {
    mapping(address => uint256) private balances;
    mapping(address => bool) public accountExists;
    address[] public accountHolders;
    address public owner;

    event AccountCreated(address indexed account);
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier accountMustExist(address account) {
        require(accountExists[account], "Account does not exist");
        _;
    }

    modifier hasSufficientBalance(address account, uint256 amount) {
        require(balances[account] >= amount, "Insufficient balance");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");

        if (!accountExists[msg.sender]) {
            accountExists[msg.sender] = true;
            accountHolders.push(msg.sender);
            emit AccountCreated(msg.sender);
        }

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external accountMustExist(msg.sender) hasSufficientBalance(msg.sender, amount) {
        require(amount > 0, "Withdrawal must be greater than 0");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external accountMustExist(msg.sender) hasSufficientBalance(msg.sender, amount) {
        require(to != address(0) && to != msg.sender, "Invalid recipient");
        require(amount > 0, "Transfer must be greater than 0");

        if (!accountExists[to]) {
            accountExists[to] = true;
            accountHolders.push(to);
            emit AccountCreated(to);
        }

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }

    function getAllAccountHolders() external view returns (address[] memory) {
        return accountHolders;
    }
}
