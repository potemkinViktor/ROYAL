const hre = require("hardhat");

async function main() {

  const URL = await ethers.getContractFactory("URL");

  const uRL = await URL.deploy();
  await uRL.deployed();

  console.log("URL deployed to:", uRL.address);
}

main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });