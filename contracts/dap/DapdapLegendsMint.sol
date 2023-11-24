// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


import "../lib/exts/AccessControl.sol";
import "../lib/exts/Strings.sol";

interface IDapdapBadge {
    function mint(address _to, uint32 _period, string memory _key) external returns(uint256);
}


contract DapdapLegendsMint is AccessControl {
    address public dap;
    mapping (uint32 => mapping (address => uint8)) public whiteList;
    mapping (uint32 => bool) public periodStoped;

    constructor(address _dap) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        dap = _dap;
    }

    // 添加白名单
    function addWhiteList(uint32 _period, address[] memory _tos) public onlyRole(DEFAULT_ADMIN_ROLE){
        uint len = _tos.length;
        for(uint i = 0; i != len; ++i){
            whiteList[_period][_tos[i]] = 1;
        }        
    }

    // 清理白名单
    function clearWhiteList(uint32 _period, address[] memory _tos) public onlyRole(DEFAULT_ADMIN_ROLE){
        uint len = _tos.length;
        for(uint i = 0; i != len; ++i){
            whiteList[_period][_tos[i]] = 0;
        }        
    }

    // 暂停某期不可mint，默认都是可mint
    function stopPeriod(uint32 _period) public onlyRole(DEFAULT_ADMIN_ROLE){
        periodStoped[_period] = true;
    }

    // 开启某期可mint
    function startPeriod(uint32 _period) public onlyRole(DEFAULT_ADMIN_ROLE){
        periodStoped[_period] = false;
    }

    // 校验是否可以mint
    function checkMint(uint32 _period, address _owner) public view returns(bool){
        if(!periodStoped[_period] && whiteList[_period][_owner] == 1){
            return true;
        }

        return false;
    }

    //获取签名
    // function getSign(address _to, string memory _key) public pure returns(bytes32){
    //     return keccak256(abi.encodePacked(Strings.toHexString(_to), _key, Strings.toHexString(_to)));
    // }

    // mint
    function mint(uint32 _period, string memory _key, bytes32 _sign) public returns(uint256){
        address _to = msg.sender;
        require(!periodStoped[_period], "Error:Closed");
        require(_sign == keccak256(abi.encodePacked(Strings.toHexString(_to), _key, Strings.toHexString(_to))), "SIGN_ERROR");
        require(whiteList[_period][_to] == 1, "Error:Not whitelisted or already minted");
        
        whiteList[_period][_to] = 2;
        return IDapdapBadge(dap).mint(_to, _period, _key);
    }
}