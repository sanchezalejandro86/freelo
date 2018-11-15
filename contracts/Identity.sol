pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./identity/ClaimHolder.sol";

contract Identity is ClaimHolder{
    address public user ;
    string public name;
    string public fullname;
    string public email;
    string public photo; //IPFS hash
    mapping(string => ERC20) public skills;

    constructor(
        address _user,
        string _name,
        string _fullname,
        string _email,
        string _photo
    )
    public{
        user = _user;
        name = _name;
        fullname = _fullname;
        email = _email;
        photo = _photo;
    }
}
