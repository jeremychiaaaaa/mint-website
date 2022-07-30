// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AudeaumusNFT is ERC721A, Ownable{
  using Strings for uint256;
  bytes32 private merkleRoot ; 
  string public baseURI = "ipfs://";
    

    uint256 public reservedForTeam = 10;
    uint256 public initialPublicPrice = 0.4 ether;
    uint256 public finalPublicPrice = 0.1 ether;
    uint256 public publicMintDuration = 20 minutes;
    uint256 public mintIntervals = 2 minutes;
    uint256 public dropPerStep =((initialPublicPrice - finalPublicPrice) / (publicMintDuration / mintIntervals));
    uint256 public whiteListPrice = 0.2 ether;

    uint256 public constant MAX_PUBLIC_SUPPLY = 9000;
    uint256 public constant MAX_WHITELIST_SUPPLY = 3000;
    uint256 public constant MAX_WHITELIST_MINT = 2;
    uint256 public constant MAX_PUBLIC_MINT = 10;

    uint256 public startAt;
   mapping(address => uint256) public totalPublicMint;
   mapping(address => uint256) public totalWhiteListMint;     
    bool public saleActive = false;
    bool public whitelistActive = false;
    bool public revealed = false;
    bool public paused = false;
    bool public teamMint = false;
    constructor() ERC721A('Audeamus', 'AUD') {
      
    }
     modifier callerIsUser() {
        require(tx.origin == msg.sender, "Please do not call this contract using another contract");
        _;
    }

    
     
    function mintReserved (uint256 _amount) public onlyOwner{
        require(teamMint, 'Team mint has not begun');
        reservedForTeam = _amount;
        teamMint = true;
        _safeMint(msg.sender, _amount);
    }

    function getAuctionPrice() public view returns(uint256){
        require(saleActive, 'Sale has not started');
        require(!paused, 'Sale has paused');
        uint256 _startSaleTime = startAt;
        if(block.timestamp < _startSaleTime){
            return initialPublicPrice;
        }
        if(block.timestamp - _startSaleTime >= publicMintDuration){
            return finalPublicPrice;
        } else {
            uint256 steps = ((block.timestamp - _startSaleTime) / mintIntervals);
            return initialPublicPrice - (steps * dropPerStep);
        }
    }

    
    

    function whiteListMint(bytes32[] calldata _merkleproof, uint256 _amount) external payable callerIsUser {
        require(whitelistActive, 'white list not active yet');
        require(totalSupply() + _amount <= MAX_WHITELIST_SUPPLY, 'The pre market white list sale limit has been hit.');
        require(msg.value >= whiteListPrice * _amount, 'Insufficient ether');
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(MerkleProof.verify(_merkleproof, merkleRoot, leaf), 'Invalid Proof');
        require(totalWhiteListMint[msg.sender] + _amount <= MAX_WHITELIST_MINT, 'Maximum of two mints per transaction');
        totalWhiteListMint[msg.sender] += _amount;
        uint256 refund =( msg.value - (whiteListPrice * _amount));
        if(refund > 0){
            payable(msg.sender).transfer(refund);
        }
        _safeMint(msg.sender, _amount);
    }

    function publicSaleMint(uint256 _quantity) external payable callerIsUser {
      require(saleActive, 'Sale has not begun yet');
      require(!paused, 'Sale has been paused');
      require(totalSupply() + _quantity <= MAX_PUBLIC_SUPPLY, 'The public sale limit has been hit.');   
      require(msg.value >= (getAuctionPrice() * _quantity), 'Insufficient ether');
      require(totalPublicMint[msg.sender] + _quantity <= MAX_PUBLIC_MINT, 'You have already minted 10 times');

      totalPublicMint[msg.sender] += _quantity;
       uint256 refund = msg.value - (getAuctionPrice() * _quantity);
        if(refund > 0){
            payable(msg.sender).transfer(refund);
        }  
        _safeMint(msg.sender, _quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

     function setURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }
    
    function tokenURI(uint256 tokenId) public view  override returns (string memory) {
        require(_exists(tokenId), 'Non existent token');
        
        if(revealed){
        string memory baseURI_ = _baseURI();    
        uint correctId = tokenId + 1;
        
        return bytes(baseURI_).length != 0 ? string(abi.encodePacked(baseURI_, Strings.toString(correctId), '.json')) : '';}
        else{
         return string(abi.encodePacked(_baseURI(),'hidden.json'));
        }

        
    }
   

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner{
        merkleRoot = _merkleRoot;
    }

    function getMerkleRoot() external view returns (bytes32){
        return merkleRoot;
    }
    function toggleTeamReveal() external onlyOwner {
        teamMint = !teamMint;
    }

    function togglePause() external onlyOwner{
        paused = !paused;
    }

    function toggleWhiteListSale() external onlyOwner{
        whitelistActive = !whitelistActive;
        
    }

    function togglePublicSale() external onlyOwner{
        saleActive = !saleActive;
        startAt = block.timestamp;
    }

    function toggleReveal() external onlyOwner{
        revealed = !revealed;
    }
    function withdraw() external onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
 
    function setInitialPublicPrice(uint _price) external onlyOwner {
        initialPublicPrice = _price;
    }
    function setFinalPublicPrice(uint _price) external onlyOwner {
        finalPublicPrice = _price;
    }
    function setPublicMintDuration(uint _time) external onlyOwner {
        publicMintDuration = _time;
    }

    function setMintIntervals(uint _time) external onlyOwner {
        mintIntervals = _time;
    }

  }

