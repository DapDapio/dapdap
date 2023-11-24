pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

library Lottery{
    
    struct LotteryValue{
        uint256 minValue;
        uint256 maxValue;
    }
    
    function random(bytes memory _seed, uint256[] memory _list) external pure returns(uint256 index_, uint256 max_, uint256 winNumber_){
        require(_list.length > 0, "list length not 0");
        
        uint256 min = 0;
        uint256 max = 0;
        LotteryValue[] memory temp = new LotteryValue[](_list.length);
        for(uint256 i = 0; i != _list.length; ++i){
            min = max;
            max += _list[i];
            temp[i] = (LotteryValue({
                minValue : min,
                maxValue : max
            }));
        }
        
        bytes32 randomHash = keccak256(_seed);
        max_ = max;
        winNumber_ = uint256(randomHash) % max;
        index_ = 0;
        for(uint256 i = 0; i != _list.length; ++i){
            uint minValue = temp[i].minValue;
            uint maxValue = temp[i].maxValue;
            if(minValue != maxValue && winNumber_ >= minValue && winNumber_ < maxValue){
                index_ = i;
                break;
            }
        }
    }

    //取指定区间的随机数
    function randomNum(bytes memory _seed, uint256 _min, uint256 _max) external pure returns(uint256){
        if(_max <= _min){
            return _max;
        }

        uint256 count = _max - _min + 1;
        bytes32 randomHash = keccak256(_seed);
        uint256 winNumber = uint256(randomHash) % count;
        return _min + winNumber;
    }
}