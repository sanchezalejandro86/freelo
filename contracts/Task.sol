pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./WorkContract.sol";

contract Task is Ownable {

    /*
     * Events
     */
    event TaskHired(WorkContract _workContract);

    /*
    * Storage
    */
    address public owner;
    address public taskRegistry; // TODO: Define interface for real TaskRegistry ?
    bytes32 public content; // IPFS hash
    uint public created;
    uint public expiration;
    uint public askPrice;
    STATE public state;
    mapping(address => BidOffer) offers;
    WorkContract workContract;

    /*
    * Modifiers
    */
    modifier hasNotExpired() {
        require(now < expiration);
        _;
    }

    /*
    * Enum
    */
    enum STATE {
        EDITING,
        PUBLISHED,
        SUSPENDED,
        CLOSED,
        HIRED
    }

    /*
    * Struct
    */
    struct BidOffer{
        address user;
        uint256 price;
        string message;
    }

    constructor(address _owner, bytes32 _content, uint _askPrice)
    public{
        taskRegistry = msg.sender; // TaskRegistry(msg.sender);
        owner = _owner;
        content = _content;
        state = STATE.EDITING;
        created = now;
        expiration = created + 30 days;
        askPrice = _askPrice;
    }

    function publish() onlyOwner hasNotExpired public {
        state = STATE.PUBLISHED;
    }

    function suspend() onlyOwner hasNotExpired public {
        state = STATE.SUSPENDED;
    }

    function close() onlyOwner hasNotExpired public {
        state = STATE.CLOSED;
    }

    function isActive() onlyOwner public pure returns (bool){
        return state != STATE.CLOSED && !isClosed();
    }

    function addOffer(address _user, uint256 _price, string _message) public{
        offers[_user] = BidOffer(_user, _price, _message);
    }

    function hireUser(address _user) hasNotExpired payable {
        require(state = STATE.PUBLISHED);

        BidOffer storage offer = offers[_user];
        require(msg.value = offer.price);
        state = STATE.HIRED;
        workContract = new WorkContract(this, _user, offer.price);
        workContract.pay.value(msg.value)();

        emit TaskHired(workContract);
    }
}
