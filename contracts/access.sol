// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract access{

    /**
     * Events
     */
    event Deposit(address indexed sender, uint amount, uint balance);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event QuorumUpdate(uint256 quorum);
    event AdminTransfer(address indexed newAdmin);
    
    /**
     * Storage
    */
    address public adminWallet;
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numMinConfs;

    /**
     * Modifiers
    */

     modifier checkNull(address _address) {
        require(_address != address(0), "Specified destination doesn't exist!");
        _;
    }

     modifier checkAdmin() {
        require(msg.sender == adminWallet, "Only admin can only use this function!");
        _;
    }

    modifier checkOwnerNotExists(address owner) {
        require(isOwner[owner] == false, "This owner already exists!");
        _;
    }

    modifier checkOwnerExists(address owner)
    {
        require(isOwner[owner]== true, "The owner should exist !");
        _;
    }
   
    

    /**
     * Public Functions
     */

    /**
    * @dev Allows admin to add new owner to the wallet
    * @param owner Address of the new owner
    */
    function addOwner(address owner) 
        public 
        checkAdmin 
        checkNull(owner)
        checkOwnerNotExists(owner)
    {
        isOwner[owner] = true;
        owners.push(owner);
        uint size = owners.length;
        numMinConfs = (3 * size)/5;
        emit OwnerAddition(owner);
    }

    /**
    * @dev Allows admin to remove owner from the wallet
    * @param owner Address of the new owner
    */
    function revokeOwner(address owner)
        public
        checkAdmin
        checkNull(owner)
        checkOwnerExists(owner)
    {
        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.pop();
    }

    /**
    * @dev Allows admin to transfer owner from one wallet to  another
    * @param _from Address of the old owner
    * @param _to Address of the new owner
    */
    function transferOwner(address _from, address _to)
        public
        checkAdmin
        checkNull(_from)
        checkNull(_to)
        checkOwnerExists(_from)
        checkOwnerNotExists(_to)
    {
        for (uint256 i = 0; i < owners.length; i++)
            if (owners[i] == _from) {
                owners[i] = _to;
                break;
            }
        isOwner[_from] = false;
        isOwner[_to] = true;
        emit OwnerRemoval(_from);
        emit OwnerAddition(_to);
    }

    /**
     * @dev Allows admin to transfer admin rights to another address
     * @param newAdmin Address of the new admin
     */
    function renounceAdmin(address newAdmin) 
        public 
        checkAdmin {
        adminWallet = newAdmin;
        emit AdminTransfer(newAdmin);
    }

    /**
     * Internal Functions
     */

    /**
     * @dev Updates the new quorum value
     * @param _owners List of address of the owners
     */
}