// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/ERC721.sol";
import "../lib/ERC721Enumerable.sol";
import "../lib/ERC721Burnable.sol";
import "../lib/exts/AccessControl.sol";
import "../lib/exts/Counters.sol";
import "../lib/exts/Pausable.sol";

contract DapdapLegends is ERC721, ERC721Enumerable, Pausable, ERC721Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    using Strings for uint256;

    string private uriPrefix = "https://app-api-prod.dapdap.io/api/memberXpLevel/nftMetadata/";
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) public idMaps;
    mapping(string => uint256) public keyMaps;
    mapping(address => mapping(uint32 => uint256)) public userPeriodMaps;

    constructor() ERC721("DapDap Legends", "DapDap Legends") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _to, uint32 _period, string memory _key) public whenNotPaused onlyRole(MINTER_ROLE) returns(uint256){
        require(0 == keyMaps[_key], "ERROR:Key error");
        require(0 == userPeriodMaps[_to][_period], "Error:Repeated");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(_to, tokenId);
        keyMaps[_key] = tokenId;
        idMaps[tokenId] = _key;
        userPeriodMaps[_to][_period] = tokenId;
        return tokenId;
    }

    function tokensOf(address _owner, uint256 _beginIndex, uint256 _endIndex) external view returns(uint256[] memory){
        require(_endIndex > _beginIndex, "ERROR:Parameter error");
        uint length = _endIndex - _beginIndex;
        uint256[] memory result = new uint256[](length);
        for(uint i = 0; i != length; ++i){
            result[i] = tokenOfOwnerByIndex(_owner, _beginIndex+i);
        }

        return result;
    }

    function setUriPrefix(string memory prefix)
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        uriPrefix = prefix;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        require(from == address(0) || to == address(0), "Non-transferable");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 _tokenId) 
        public 
        view 
        override 
        returns (string memory) 
    {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(uriPrefix, idMaps[_tokenId], "/", _tokenId.toString()));
    }
}