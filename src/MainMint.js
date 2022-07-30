import { useState, useEffect } from "react";
import { ethers, BigNumber } from "ethers";
import audeaumusNFT from './audeaumusNFT.json'
import { Box, Button, Flex, Input, Text, Spacer } from '@chakra-ui/react';
import { formatBytes32String } from "@ethersproject/strings";
import  { verifyWhiteList } from './api/whiteList'
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const audeaumusNFTAddress = "0xC25C53b67F36fFDfeAC6c26e558c9B339a3f14e7"
const MainMint = ({accounts,setAccounts}) => {
    const [mintAmount, setMintAmount] = useState(1)
    const [message, setMessage] = useState('')
    
    const isConnected = Boolean(accounts[0])
     const activeAccount = accounts[0]
    



    async function handleMint() {
        if(window.ethereum){
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            const signer = provider.getSigner()
            setMessage('Awaiting')
         
            
            
             const contract = new ethers.Contract(
                      audeaumusNFTAddress,
                      audeaumusNFT.abi,
                      signer
                  )
            const hexAccount = keccak256(activeAccount)
            console.log(hexAccount)
                  const verified = await verifyWhiteList()
                 
                  console.log(verified.data)
                  console.log(Array.isArray(verified.data))
                  const leaf = (verified.data).map(x => keccak256((x)));
                  console.log(leaf)
                  const tree = new MerkleTree(leaf, keccak256, {sortPairs:true})
                  console.log(tree)
            const hexProof = (tree.getHexProof(hexAccount))
            hexProof.forEach(i => i.replace(/[']+/g, ''))
            hexProof.forEach(i => BigNumber.from(i))
           
            try {
               
               
                     const response = await contract.whiteListMint(hexProof,BigNumber.from(mintAmount),{
                    value: ethers.utils.parseEther((0.2 * mintAmount).toString()),
                   
                }) //solidity requires mintAmount to be in bigNumber
                console.log('response: ' + response)
                  let message = `Confirm minting ${mintAmount}? Please sign below`
                  let signature = await signer.signMessage(message)
                  setMessage('Transaction Success')
                  
            } catch (err){
               
               const errMessage = err.error.message
               if(errMessage.includes('Maximum of two mints')){
                setMessage('Transaction Declined: Max 2 per account ')
            } else if(errMessage.includes('insufficient funds')){
                setMessage('Transaction Declined: Insufficient ether')
            } else if(errMessage.includes('Invalid Proof')){
                setMessage('Transaction Declined: This is not a whitelisted address!')
            } else {
                  setMessage('no go')
            }
           
           
            }
          

        }
       
    }
   
    const handleDecrement = () => {
        if(mintAmount < 1) return;
         setMintAmount(mintAmount - 1)
    }

    const handleIncrement = () => {
        if(mintAmount > 11) return; //not allowing more than 11
         setMintAmount(mintAmount + 1)
    }

    const handleChange = (e) => {
        setMintAmount(e.target.value)
    }
    return (
        
        <Flex justify="center" height="100vh" align="center" paddingBottom="250px">
            <Box width="520px">
            <Text fontSize="48px" boxShadow= "0 5px #000000">AudeaumusNFT</Text>
            <p>Mint now to suck JORDAN RAYMAN THOMAS OFF</p>
            {isConnected? (
                <div>
                    <div>
                        <button onClick = {handleDecrement}>-</button>
                        <input type='number' value={mintAmount} onChange={handleChange} />
                        <button onClick={handleIncrement}>+</button>
                    </div>
                    
                    <button onClick ={handleMint}>MINT NOW</button>
                    <hr />
                    <h1>{message}</h1>
                    
                </div>
            ) : (
                <p>You are not connected. Please connect to mint</p>
            ) }
            </Box>
        </Flex>
    )
}

export default MainMint