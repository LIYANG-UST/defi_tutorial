// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DappToken.sol";
import "./interfaces/IDAppToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    address public owner;
    uint256 public rewardPerSecond = 1e17;

    /// @notice Complex variables
    struct UserInfo {
        uint256 lastRewardTime;
        uint256 stakingBalance;
    }
    mapping(address => UserInfo) public userInfo;

    address[] public stakers;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    /// @notice Contract interfaces that need interaction.
    IDAppToken public dappToken;
    IERC20 public mockUSD;

    constructor(address _dappToken, address _mockUSD) {
        dappToken = IDAppToken(_dappToken);
        mockUSD = IERC20(_mockUSD);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function getStakingBalance(address _userAddress)
        public
        view
        returns (uint256)
    {
        return userInfo[_userAddress].stakingBalance;
    }

    function stake(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "amount cannot be 0");

        // Trasnfer Mock USD tokens to this contract for staking
        mockUSD.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        userInfo[msg.sender].stakingBalance += _amount;

        // Update lastRewardTime
        if (userInfo[msg.sender].lastRewardTime == 0) {
            userInfo[msg.sender].lastRewardTime = block.timestamp;
        }

        // Add user to stakers array *only* if they haven't staked already
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    function unstake() public {
        // Fetch staking balance
        uint256 balance = userInfo[msg.sender].stakingBalance;

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer Mock Dai tokens to this contract for staking
        mockUSD.transfer(msg.sender, balance);

        // Reset staking balance
        userInfo[msg.sender].stakingBalance = 0;

        userInfo[msg.sender].lastRewardTime = block.timestamp;

        // Update staking status
        isStaking[msg.sender] = false;
    }

    // Issuing Tokens
    function issueTokens() public onlyOwner {
        // Issue tokens to all stakers
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 timeLength = block.timestamp -
                userInfo[recipient].lastRewardTime;
            uint256 pendingReward = rewardPerSecond * timeLength;
            if (pendingReward > 0) {
                dappToken.transfer(recipient, pendingReward);
            }
            userInfo[recipient].lastRewardTime = block.timestamp;
        }
    }
}
