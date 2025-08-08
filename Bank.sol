// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public immutable admin; // 合约部署时只初始化一次
    mapping(address => uint) public balances;
    address[] private depositors;

    constructor() {
        //构造函数执行的时候指定部署合约的人就是管理员
        admin = msg.sender;
    }

    receive() external payable {
        if (balances[msg.sender] == 0) {
            depositors.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    // 获取topK数据
    function getBalancesTop() public view returns (address[3] memory topAddrs, uint[3] memory topBalances) {
        uint len = depositors.length;

        address[] memory addrs = depositors;
        uint[] memory bals = new uint[](len);

        for (uint i = 0; i < len; i++) {
            bals[i] = balances[addrs[i]];
        }

        for (uint i = 0; i < len; i++) {
            for (uint j = i+1; j < len;j++){
                if (bals[i] < bals[j]) {

                    // 交换余额
                    uint balsTemp = bals[i];
                    bals[i] = bals[j];
                    bals[j] = balsTemp;

                    // 交换地址
                    address addrTemp = addrs[i];
                    addrs[i] = addrs[j];
                    addrs[j] = addrTemp;
                }
            }
        }

        // 获取前top3
        for (uint i  = 0; i < 3; i++) {
            topAddrs[i] = addrs[i];
            topBalances[i] = bals[i];
        }
        return (topAddrs,topBalances);
    }


    // 管理员权限
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