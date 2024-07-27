// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenStaking is Ownable {
    IERC20 public stakingToken;
    uint256 public rewardRate; // Reward rate per second per token staked

    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount, uint256 time);
    event Unstaked(address indexed user, uint256 amount, uint256 reward, uint256 time);
    event RewardRateChanged(uint256 newRate);

    constructor(IERC20 _stakingToken, uint256 _initialRewardRate, address initialOwner) Ownable(initialOwner) {
        stakingToken = _stakingToken;
        rewardRate = _initialRewardRate;
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
        emit RewardRateChanged(_rewardRate);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        stakingToken.transferFrom(msg.sender, address(this), _amount);

        if (stakes[msg.sender].amount > 0) {
            rewards[msg.sender] += calculateReward(msg.sender);
        }

        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].startTime = block.timestamp;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function unstake() external {
        require(stakes[msg.sender].amount > 0, "No tokens staked");

        uint256 stakedAmount = stakes[msg.sender].amount;
        uint256 reward = calculateReward(msg.sender);

        stakingToken.transfer(msg.sender, stakedAmount);
        rewards[msg.sender] += reward;

        delete stakes[msg.sender];

        emit Unstaked(msg.sender, stakedAmount, reward, block.timestamp);
    }

    function calculateReward(address _staker) internal view returns (uint256) {
        Stake memory stakeData = stakes[_staker];
        uint256 duration = block.timestamp - stakeData.startTime;
        return stakeData.amount * rewardRate * duration;
    }

    function claimRewards() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);
    }
}
