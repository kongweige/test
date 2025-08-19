// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// BaseERC20本质是一个公共账本，本质上所有token的流转都是还是在合约内，是不过是从一个地址转移到另一个地址
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
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10**uint256(decimals); // 100,000,000 tokens

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // 自己普通转账
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;
    }

    // 类似授权商家扣款
    // from 实际代币拥有者，to 收款方，msg.sender转账人（授权地址）
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowances[_from][msg.sender] >= _value, "ERC20: allowance exceeded");
        require(balances[_from] >= _value, "ERC20: balance too low");
        require(_to != address(0), "ERC20: transfer to the zero address");

        balances[_from] -= _value;
        balances[_to]   += _value;

        allowances[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        return allowances[_owner][_spender];
    }
}
