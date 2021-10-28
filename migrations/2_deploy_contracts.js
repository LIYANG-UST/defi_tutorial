const DAppToken = artifacts.require("DAppToken");
const MockUSD = artifacts.require("MockUSD");
const TokenFarm = artifacts.require("TokenFarm");

module.exports = async function(deployer, network, accounts) {
  // Deploy MockUSD Token
  await deployer.deploy(MockUSD);

  // Deploy DAppToken
  await deployer.deploy(DAppToken);

  // Deploy TokenFarm
  await deployer.deploy(TokenFarm, DAppToken.address, MockUSD.address);

  // Transfer all tokens to TokenFarm (1 million)
  const dappToken = await DAppToken.deployed();
  const tokenFarm = await TokenFarm.deployed();
  const init_amount = web3.utils.toWei("1000000", "ether");
  await dappToken.mint(tokenFarm.address, init_amount);
};
