// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Interface for ERC20 DAI contract
interface DAI {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function balanceOf(address) external view returns (uint256);
}


interface aDAI {
    function balanceOf(address) external view returns (uint256);
}

// Interface for Aave's lending pool contract
interface AaveLendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;

    function getReserveData(address asset)
        external
        returns (
            uint256 configuration,
            uint128 liquidityIndex,
            uint128 variableBorrowIndex,
            uint128 currentLiquidityRate,
            uint128 currentVariableBorrowRate,
            uint128 currentStableBorrowRate,
            uint40 lastUpdateTimestamp,
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress,
            address interestRateStrategyAddress,
            uint8 id
        );
}

contract AaveLiquidity {
    using SafeMath for uint256;

    string public name = "Aave Liquidity";
    address public owner;
    
    DAI dai = DAI(0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F);
    aDAI aDai = aDAI(0x639cB7b21ee2161DF9c882483C9D55c90c20Ca3e);
    AaveLendingPool aaveLendingPool = AaveLendingPool(0x9198F13B08E299d85E096929fA9781A1E3d5d827);
  
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    constructor() public {
        owner = msg.sender;
    }

  
     // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function claimContractfunds() public onlyOwner {
        // Once we have the funds, transfer back to owner
        uint256 balance = dai.balanceOf(address(this));
        require(dai.approve(address(this), balance));
        dai.transfer(msg.sender, balance);

    }


    function _depositToAave(uint256 _amount) public onlyOwner returns (uint256) {
        require(dai.approve(address(aaveLendingPool), _amount));
        aaveLendingPool.deposit(address(dai), _amount, address(this), 0);
    }

    function _withdrawFromAave() public onlyOwner {
        uint256 balance = aDai.balanceOf(address(this));
        aaveLendingPool.withdraw(address(dai), balance, address(this));
    }

    
    function balanceOfContract() public view returns (uint256) {
       return aDai.balanceOf(address(this));
        
    }

   
}
