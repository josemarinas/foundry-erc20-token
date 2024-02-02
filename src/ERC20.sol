// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    address private _deployer;

    mapping(address owner => uint256) private _balances;
    mapping(address owner => mapping(address spender => uint256))
        private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    error InvalidReceiver(address);
    error InvalidSender(address);
    error InvalidSpender(address);
    error InsufficientFounds();
    error SenderIsNotDeployer();
    error InsufficientAllowance(uint256);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _deployer = msg.sender;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function mint(address _to, uint256 _value) public virtual {
        if (msg.sender != _deployer) {
            revert SenderIsNotDeployer();
        }
        if (_to == address(0)) {
            revert InvalidReceiver(address(0));
        }
        _totalSupply += _value;
        _balances[_to] += _value;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (_to == address(0)) {
            _balances[msg.sender] -= _value;
            _totalSupply -= _value;
            return true;
        }
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (_to == address(0)) {
            revert InvalidReceiver(address(0));
        }
        if (_from == address(0)) {
            revert InvalidSender(address(0));
        }
        uint256 currentAllowance = _allowances[_from][msg.sender];
        if (currentAllowance < _value) {
            revert InsufficientAllowance(currentAllowance);
        }
        _allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        if (balanceOf(_from) < _value) {
            revert InsufficientFounds();
        }
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        if (_spender == address(0)) {
            revert InvalidSpender(address(0));
        }
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}
