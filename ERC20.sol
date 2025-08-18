// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 设置 Token 名称（name）："BaseERC20"
// 设置 Token 符号（symbol）："BERC20"
// 设置 Token 小数位decimals：18
// 设置 Token 总量（totalSupply）:100,000,000
// 允许任何人查看任何地址的 Token 余额（balanceOf）

// 允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
// 允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
// 允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
// 允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；

// 本质是BaseERC20是一个公共账本，本质上所有token的流转都是还是在合约内，是不过是从一个地址转移到另一个地址
contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // 自己普通转账
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;
    }

    // 类似授权商家扣款
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here


        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     

    }
}