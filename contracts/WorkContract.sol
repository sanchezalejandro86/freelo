pragma solidity ^0.4.23;

import "./Task.sol";

contract WorkContract {
    /*
     * Events
     */
    event WorkContractChange(Stages stage);
    event WorkReview(address reviewer, address reviewee, Roles revieweeRole, uint8 rating, bytes32 ipfsHash);

    /*
    * Storage
    */
    Stages internal internalStage = Stages.AWAITING_PAYMENT;
    Task taskContract;
    address worker;
    uint price;
    uint created;
    uint endDate;

    /*
    * Enum
    */
    enum Stages {
        AWAITING_PAYMENT, // Buyer hasn't paid full amount yet
        IN_ESCROW, // Payment has been received but not distributed to seller
        CLIENT_PENDING,
        WORKER_PENDING,
        IN_DISPUTE, // We are in a dispute
        REVIEW_PERIOD, // Time for reviews (only when transaction did not go through)
        COMPLETE // It's all over
    }

    enum Roles {
        CLIENT,
        WORKER
    }

    /*
    * Modifiers
    */
    modifier isClient() {
    require(msg.sender == taskContract.owner());
        _;
    }

    modifier isWorker() {
        require(msg.sender == worker);
        _;
    }

    modifier atStage(Stages _stage) {
        require(stage() == _stage);
        _;
    }

    constructor(
        address _taskContractAddress,
        address _worker,
        uint _price,
        uint _duration
    ) public{
        taskContract = Task(_taskContractAddress);
        worker = _worker;
        price = _price;
        created = now;
        endDate = now + _duration;

        emit WorkContractChange(internalStage);
    }

    // Pay for publication
    function pay()
    public
    payable
    atStage(Stages.AWAITING_PAYMENT)
    {
        setStage(Stages.IN_ESCROW);
    }

    function workerConfirmDelivery()
    public
    isWorker
    atStage(Stages.IN_ESCROW)
    {
        require(endDate >= now);
        setStage(Stages.CLIENT_PENDING);
    }

    function clientConfirmReceipt(uint8 _rating, bytes32 _ipfsHash)
    public
    isClient
    atStage(Stages.CLIENT_PENDING)
    {
        // Checks
        require(_rating >= 1);
        require(_rating <= 5);

        // State changes
        setStage(Stages.WORKER_PENDING);

        // Events
        emit WorkReview(taskContract.owner(), worker, Roles.WORKER, _rating, _ipfsHash);

    }

    function workerCollectPayout(uint8 _rating, bytes32 _ipfsHash)
    public
    isWorker
    atStage(Stages.WORKER_PENDING)
    {
        // Checks
        require(_rating >= 1);
        require(_rating <= 5);

        // State changes
        setStage(Stages.COMPLETE);

        // Events
        emit WorkReview(worker, taskContract.owner(), Roles.CLIENT, _rating, _ipfsHash);

        // Transfers
        // Send contract funds to client (ie owner of Task)
        // Transfering money always needs to be the last thing we do, do avoid
        // rentrancy bugs. (Though here the client would just be getting their own money)
        taskContract.owner().transfer(address(this).balance);
    }

    function openDispute()
    public
    {
        // Must be worker or client
        require(
            (msg.sender == worker) ||
            (msg.sender == taskContract.owner())
        );

        // Must be in a valid stage
        require(
            (stage() == Stages.WORKER_PENDING) ||
            (stage() == Stages.CLIENT_PENDING)
        );

        setStage(Stages.IN_DISPUTE);

        // TODO: Create a dispute contract?
        // Right now there's no way to exit this state.
    }

    function stage()
    public
    view
    returns (Stages _stage)
    {
        return internalStage;
    }

    function setStage(Stages _stage)
    internal
    {
        internalStage = _stage;
        emit WorkContractChange(_stage);
    }
}