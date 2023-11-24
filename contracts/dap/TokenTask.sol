// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


import "../lib/exts/AccessControl.sol";
import "../lib/exts/Pausable.sol";
import "../lib/IERC20Metadata.sol";
import "../lib/IERC721.sol";

contract TokenTask is Pausable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct TaskInfo{
        bool received;
        uint256 amount;
    }

    // taskId => ((owner => (token => amount))
    mapping(uint32 => mapping(address => mapping(address => TaskInfo))) private taskRewards;

    event RewardAdd(uint32 indexed taskId, address indexed owner, address indexed token, uint256 amount);
    event RewardReceived(uint32 indexed taskId, address indexed owner, address indexed token, uint256 amount);

    constructor(address _minter){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, _minter);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function checkReword(uint32 _taskId, address _owner, address _token) public view returns(bool,uint256){
        TaskInfo memory ti = taskRewards[_taskId][_owner][_token];
        return (ti.received,ti.amount);
    }

    function setRewards(uint32[] memory _taskIds, address[] memory _owners, address[] memory _tokens, uint256[] memory _amounts) 
        public 
        onlyRole(MINTER_ROLE)
    {
        uint length = _taskIds.length;
        require(length > 0 && length == _owners.length && length == _tokens.length && length == _amounts.length, "ERROR:error");

        for(uint i = 0; i != length; ++i){
            TaskInfo storage ti = taskRewards[_taskIds[i]][_owners[i]][_tokens[i]];
            require(!ti.received && ti.amount == 0, "ERROR:error");
            ti.received = false;
            ti.amount = _amounts[i];

            emit RewardAdd(_taskIds[i], _owners[i], _tokens[i], ti.amount);
        }
    }

    function claim(uint32 _taskId, address _token) 
        public 
        whenNotPaused 
    {
        address _owner = msg.sender;
        TaskInfo storage ti = taskRewards[_taskId][_owner][_token];
        require(!ti.received && ti.amount > 0, "ERROR: Balance is insufficient");
        ti.received = true;
        
        if(_token == address(0)){
            address payable _to = payable(_owner);
            _to.transfer(ti.amount);
        }else{
            require(IERC20(_token).transfer(_owner, ti.amount), "ERROR:Transfer error");
        }
        

        emit RewardReceived(_taskId, _owner, _token, ti.amount);
    }

    function withdraw(address payable _to, uint256 _amount) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        _to.transfer(_amount);
    }

    function withdrawToken(address _to, address _token, uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(_token).transfer(_to, _amount);
    }

    function withdrawNft(address _to, address _nft, uint256[] memory _nftIds) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint length = _nftIds.length;
        for(uint i = 0; i != length; ++i){
            IERC721(_nft).transferFrom(address(this), _to, _nftIds[i]);
        }
    }

    fallback () payable external {
        
    }
    
    receive () payable external {
        
    }
}