pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Task.sol";

contract TaskRegistry is Ownable{
    /*
    * Events
    */
    event NewTask(uint _index, address _address);

    /*
    * Storage
    */
    address[] public tasks;
    mapping(address => bool) tasksMap;

    /// @dev tasksLength(): Return number of tasks
    function tasksLength()
    public
    constant
    returns (uint)
    {
        return tasks.length;
    }

    /// @dev getTaskAddress(): Return task address
    /// @param _index the index of the task
    function getTaskAddress(uint _index)
    public
    constant
    returns (address)
    {
        return tasks[_index];
    }

    /// @dev create(): Create a new task
    /// @param _ipfsHash Hash of data on ipfsHash
    /// @param _price Ask price in wei
    function create(
        bytes32 _ipfsHash,
        uint _price
    )
    public
    returns (uint)
    {
        Task newTask = new Task(msg.sender, _ipfsHash, _price);
        tasks.push(newTask);
        tasksMap[newTask] = true;

        emit NewTask(tasksLength() - 1, address(newTask));
        return tasks.length;
    }

    function isTrustedTask(
        address _taskAddress
    )
    public
    view
    returns(bool)
    {
        return tasksMap[_taskAddress];
    }
}