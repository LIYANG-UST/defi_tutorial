const MockUSD = artifacts.require("MockUSD");
const DAppToken = artifacts.require("DAppToken");
const TokenFarm = artifacts.require("TokenFarm");

require("chai")
  .use(require("chai-as-promised"))
  .should();

function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

contract("TokenFarm", ([owner, investor]) => {
  let mockUSD, dappToken, tokenFarm;

  before(async () => {
    // Load Contracts
    mockUSD = await MockUSD.new();
    dappToken = await DAppToken.new();
    tokenFarm = await TokenFarm.new(dappToken.address, mockUSD.address);

    // Transfer all Dapp tokens to farm (1 million)
    await dappToken.mint(tokenFarm.address, tokens("1000000"), { from: owner });

    // Send tokens to investor
    await mockUSD.transfer(investor, tokens("100"), { from: owner });
  });

  describe("Mock USD deployment", async () => {
    it("has a name", async () => {
      const name = await mockUSD.name();
      assert.equal(name, "MockUSD");
    });
  });

  describe("DApp Token deployment", async () => {
    it("has a name", async () => {
      const name = await dappToken.name();
      assert.equal(name, "DAppToken");
    });
  });

  describe("Token Farm deployment", async () => {
    it("has a name", async () => {
      const name = await tokenFarm.name();
      assert.equal(name, "Dapp Token Farm");
    });

    it("contract has tokens", async () => {
      let balance = await dappToken.balanceOf(tokenFarm.address);
      assert.equal(balance.toString(), tokens("1000000"));
    });
  });

  describe("Farming tokens", async () => {
    it("rewards investors for staking MockUSD tokens", async () => {
      let result;

      // Check investor balance before staking
      result = await mockUSD.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "investor Mock USD wallet balance correct before staking"
      );

      // Stake Mock DAI Tokens
      await mockUSD.approve(tokenFarm.address, tokens("100"), {
        from: investor,
      });
      await tokenFarm.stake(tokens("100"), { from: investor });

      // Check staking result
      result = await mockUSD.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("0"),
        "investor Mock USD wallet balance correct after staking"
      );

      result = await mockUSD.balanceOf(tokenFarm.address);
      assert.equal(
        result.toString(),
        tokens("100"),
        "Token Farm Mock USD balance correct after staking"
      );

      result = await tokenFarm.getStakingBalance(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "investor staking balance correct after staking"
      );

      result = await tokenFarm.isStaking(investor);
      assert.equal(
        result.toString(),
        "true",
        "investor staking status correct after staking"
      );

      // Issue Tokens
      await tokenFarm.issueTokens({ from: owner });

      // Check balances after issuance
      result = await dappToken.balanceOf(investor);
      assert.isAbove(
        parseInt(result),
        0,
        "investor DApp Token wallet balance larger than 0 affter issuance"
      );

      // Ensure that only onwer can issue tokens
      await tokenFarm.issueTokens({ from: investor }).should.be.rejected;

      // Unstake tokens
      await tokenFarm.unstake({ from: investor });

      // Check results after unstaking
      result = await mockUSD.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "investor Mock USD wallet balance correct after staking"
      );

      result = await mockUSD.balanceOf(tokenFarm.address);
      assert.equal(
        result.toString(),
        tokens("0"),
        "Token Farm Mock USD balance correct after staking"
      );

      result = await tokenFarm.getStakingBalance(investor);
      assert.equal(
        result.toString(),
        tokens("0"),
        "investor staking balance correct after staking"
      );

      result = await tokenFarm.isStaking(investor);
      assert.equal(
        result.toString(),
        "false",
        "investor staking status correct after staking"
      );
    });
  });
});
