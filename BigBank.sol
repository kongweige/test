// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function getBalancesTop() external view returns (address[3] memory topAddrs, uint[3] memory topBalances);
    function withdraw() external;
}

// 实际部署合约的时候只需要部署Bigbank和admin，Bank作为一个封装好的功能模块
contract Bank is IBank {
    
    // 管理员
    address public admin; // 修改 admin 为可变,允许管理员转移

    mapping(address => uint) public balances;
    address[] public depositors;

    constructor() {
        admin = msg.sender;
    }

    // 用户存钱
    receive() external payable virtual {
        if (balances[msg.sender] == 0) {
            depositors.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    // 获取topK数据
    function getBalancesTop() external view returns (address[3] memory topAddrs, uint[3] memory topBalances) {
        uint len = depositors.length;
        address[] memory addrs = depositors;
        uint[] memory bals = new uint[](len);

        for (uint i = 0; i < len; i++) {
            bals[i] = balances[addrs[i]];
        }

        for (uint i = 0; i < len; i++) {
            for (uint j = i+1; j < len; j++) {
                if (bals[i] < bals[j]) {
                    (bals[i], bals[j]) = (bals[j], bals[i]);
                    (addrs[i], addrs[j]) = (addrs[j], addrs[i]);
                }
            }
        }

        uint topCount = len < 3 ? len : 3;
        for (uint i = 0; i < topCount; i++) {
            topAddrs[i] = addrs[i];
            topBalances[i] = bals[i];
        }
        return (topAddrs, topBalances);
    }

    // 管理员取钱（银行提款功能，管理员能动用银行里的钱，普通用户不能）
    function withdraw() external {
        // 检查调用者是否为管理员
        require(msg.sender == admin, "Only admin can withdraw");
        
        // 获取合约余额
        uint balance = address(this).balance;
        
        // 确保有余额可提取
        require(balance > 0, "No balance to withdraw");
        
        // 将所有ETH转给管理员
        (bool success, ) = admin.call{value: balance}("");
        require(success, "Withdrawal failed");
    }
}

// BigBank 合约
contract BigBank is Bank {

    // 修饰符：(类似python中的装饰器)
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be > 0.001 ether");
        _;
    }

    receive() external payable minDeposit override {
        if (balances[msg.sender] == 0) {
            depositors.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    function transferAdmin(address newAdmin) external {
        // 调用地址必须是初始地址（管理员）
        require(msg.sender == admin, "Only admin can transfer");
        require(newAdmin != address(0), "New admin cannot be zero address");
        // 防止输入的是EOA地址
        require(newAdmin.code.length > 0, "New admin must be a contract");
        // 权限转移
        admin = newAdmin;
    }
}

// Admin 合约
contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    // 从BigBank合约中提取余额
    function adminWithdraw(IBank bank) external onlyOwner {
        bank.withdraw();
    }
    
    receive() external payable {}

    function getBalance() external view returns (uint) {
       return address(this).balance;
    }
}
