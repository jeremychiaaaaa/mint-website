
const hre = require("hardhat");

async function main() {

  const AudeaumusNFT = await hre.ethers.getContractFactory("AudeaumusNFT");
  const audeaumusNFT = await AudeaumusNFT.deploy();

  await audeaumusNFT.deployed();

  console.log("AudeaumusNFT deployed to:", audeaumusNFT.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
