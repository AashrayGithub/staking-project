async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy the ERC20 token
    const MyToken = await ethers.getContractFactory("MyToken");
    const initialSupply = ethers.utils.parseUnits("1000000", 18); // 1,000,000 tokens
    const myToken = await MyToken.deploy(initialSupply);
    await myToken.deployed();

    console.log("MyToken deployed to:", myToken.address);

    // Deploy the TokenStaking contract
    const TokenStaking = await ethers.getContractFactory("TokenStaking");
    const initialRewardRate = ethers.utils.parseUnits("0.1", 18); // Example reward rate
    const tokenStaking = await TokenStaking.deploy(myToken.address, initialRewardRate, deployer.address);
    await tokenStaking.deployed();

    console.log("TokenStaking deployed to:", tokenStaking.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
