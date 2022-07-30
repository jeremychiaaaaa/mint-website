const express = require('express');
const keccak256 = require('keccak256');
const router = express.Router();
const {MerkleTree} = require('merkletreejs');


let whiteListAccounts = [
    "0x0af5Ef06CE7e31ECAA3aA0B353c43351D86a92BC",
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
    "0x17F6AD8Ef982297579C203069C1DbfFE4348c372",
    "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678",
    "0x3b050969b792379F7E0647Dd15593049547f533c",
    "0x70F3A96c8b679B71A7151f4DEF9274398FE08E0c"
];



router.get("/address", (req,res,next) => {
    try {
       
   
             res.status(200).json({data: whiteListAccounts})
        }
       
     catch (err){
        res.status(400)
    }
    
})

module.exports = router;