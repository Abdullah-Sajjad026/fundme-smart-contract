import { ethers, network } from "hardhat";
import verifyContract from "../utils/verify-contract";
import { developmentChains, networksConfig } from "../helper-hardhat-config";

async function main() {
  let priceFeedAddress;
  const [deployer] = await ethers.getSigners();

  if (!developmentChains.includes(network.name)) {
    priceFeedAddress =
      networksConfig[network.name as keyof typeof networksConfig]
        .priceFeedAddress;
  }

  const FundMe = await ethers.getContractFactory("FundMe", {
    signer: deployer,
  });

  console.log("Deploying FundMe contract with the account:", deployer.address);
  const deploymentReceipt = await FundMe.deploy(
    priceFeedAddress || "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"
  );
  const fundMe = await deploymentReceipt.waitForDeployment();

  const deployTx = fundMe.deploymentTransaction();
  await deployTx?.wait(6);

  const contractAddress = await fundMe.getAddress();
  console.log("FundMe deployed to:", contractAddress);

  // verifying contract
  verifyContract(contractAddress, [priceFeedAddress]);

  const fundTx = await fundMe.fund({
    value: ethers.parseEther("0.029"),
    from: deployer.address,
  });
  await fundTx.wait();

  console.log("Funded contract with: ", fundTx.value.toString());

  console.log("Funder address: ", await fundMe.getSpecificFunder(1));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
