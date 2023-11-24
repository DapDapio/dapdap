// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/ERC721.sol";
import "../lib/ERC721Enumerable.sol";
import "../lib/ERC721Burnable.sol";
import "../lib/exts/AccessControl.sol";
import "../lib/exts/Counters.sol";
import "../lib/exts/Pausable.sol";

contract DapdapBadge is ERC721, ERC721Enumerable, Pausable, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    string private uriPrefix = "https://app-api-prod.dapdap.io/api/game/badge/metadata1/";
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) public idMaps;
    mapping(string => uint256) public keyMaps;

    constructor() ERC721("DapDap Game Level Badges", "DapDap Badges") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(string memory _key, bytes32 _sign) public whenNotPaused returns(uint256){
        address _to = msg.sender;
        require(_sign == keccak256(abi.encodePacked(Strings.toHexString(_to), _key, Strings.toHexString(_to))), "ERROR:SIGN_ERROR");
        require(0 == keyMaps[_key], "ERROR:Key error");


        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(_to, tokenId);
        keyMaps[_key] = tokenId;
        idMaps[tokenId] = _key;
        return tokenId;
    }

    function mintByAdmin(address[] memory _tos, uint256[] memory _ids, string[] memory _keys) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE){
        uint len = _tos.length;
        require(len == _ids.length && len == _keys.length, "ERROR:error");

        for(uint i = 0; i < len; ++i){
            string memory _key = _keys[i];
            uint256 _tokenId = _ids[i];
            require(0 == keyMaps[_key], "ERROR:Key error");
            _safeMint(_tos[i], _tokenId);
            keyMaps[_key] = _tokenId;
            idMaps[_tokenId] = _key;

            _tokenIdCounter.increment();
        }
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
        require(from == address(0) || to == address(0), "soulbound");
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

    function approve(address to, uint256 tokenId) public pure override(ERC721,IERC721) {
        to; tokenId;
        require(false, "soulbound!");
    }

    function isApprovedForAll(address owner, address operator) public view virtual override(ERC721,IERC721) returns (bool) {
        owner;operator;
        require(false, "soulbound!");
        return false;
    }

    function getApproved(uint256 tokenId) public pure override(ERC721,IERC721) returns (address) {
        tokenId;
        require(false, "soulbound!");
        return  address(0);
    }

    function setApprovalForAll(address operator, bool approved) public pure override(ERC721,IERC721) {
        operator;approved;
        require(false, "soulbound!");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721,IERC721) {
        from;to;tokenId;
        require(false, "soulbound!");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721,IERC721) {
        from;to;tokenId;
        require(false, "soulbound!");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override(ERC721,IERC721) {
       from;to;tokenId;_data;
       require(false, "soulbound!");
    }
}