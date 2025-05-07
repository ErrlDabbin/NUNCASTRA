// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nuncastra is ERC721, Ownable {
    uint256 public tokenCounter;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public salePrices;
    mapping(uint256 => address) public creators;

    constructor() ERC721("Nuncastra", "NASTRA") {}

    function mint(string memory tokenURI) external {
        uint256 tokenId = tokenCounter++;
        _safeMint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenURI;
        creators[tokenId] = msg.sender;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function list(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        salePrices[tokenId] = price;
    }

    function buy(uint256 tokenId) external payable {
        uint256 price = salePrices[tokenId];
        require(price > 0 && msg.value >= price, "Invalid payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        salePrices[tokenId] = 0;

        uint256 royalty = (msg.value * 10) / 100;
        payable(creators[tokenId]).transfer(royalty);
        payable(seller).transfer(msg.value - royalty);
    }
}
