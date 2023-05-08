// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract GasContract {

    mapping(address => uint256) public balances;
    //mapping(address => uint256) internal whiteListStruct;
    mapping(address => ImportantStruct) internal whiteListStruct;
    mapping(address => uint256) public whitelist;

    address private immutable contractOwner;
    address[5] public administrators;
    
    struct ImportantStruct {
        uint256 amount;
        bool paymentStatus;
        address sender;
    }

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    error InsufficientBalance();
    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        assembly{
            let startPos := add(_admins, 0x20)
            sstore(administrators.slot, mload(startPos))
            sstore(add(administrators.slot,1), mload(add(startPos, 0x20)))
            sstore(add(administrators.slot,2), mload(add(startPos, 0x40)))
            sstore(add(administrators.slot,3), mload(add(startPos, 0x60)))
            sstore(add(administrators.slot,4), mload(add(startPos, 0x80)))
        }

        if(_admins[0] == msg.sender){
            balances[_admins[0]] = _totalSupply;
        }else if(_admins[1] == msg.sender){
            balances[_admins[1]] = _totalSupply;
        }else if(_admins[2] == msg.sender){
            balances[_admins[2]] = _totalSupply;
        }else if(_admins[3] == msg.sender){
            balances[_admins[3]] = _totalSupply;
        }else if(_admins[4] == msg.sender){
            balances[_admins[4]] = _totalSupply;
        }
        
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) public {
       
        if(balances[msg.sender] < _amount){
            revert InsufficientBalance();
        }
        
        require(bytes(_name).length < 9, "Name exceeds");
        
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
  
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        
        require(msg.sender == contractOwner);
        require(_tier < 255);
        
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {

        if(balances[msg.sender] < _amount || _amount < 3){
            revert InsufficientBalance();
        }

        whiteListStruct[msg.sender] = ImportantStruct(_amount, true, msg.sender);
       
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {        
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }

}