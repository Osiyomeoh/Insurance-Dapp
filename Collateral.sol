// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./InsuranceLiquidityPool.sol";
import "./Factory.sol";

contract CollateralLoanInsurance {
    address public owner;
    enum InsuranceType { Standard, Enhanced }
    struct LoanPolicy {
        InsuranceType insuranceType;
        uint256 loanAmount;
        uint256 premium;
        uint256 coveragePercentage;
        bool active;
    }
    mapping(address => LoanPolicy) public loanPolicies;

    // Events
    event InsuranceApplied(address insured, InsuranceType insuranceType, uint256 loanAmount, uint256 coveragePercentage, uint256 premium);
    event InsuranceClaimed(address insured, uint256 claimAmount);
    event InsuranceClaimed(address insured, uint256 claimAmount, uint256 payout);
    event PayoutAmountCalculated(address policyHolder, uint256 payoutAmount);



    InsuranceLiquidityPool private liquidityPool;

       address public factoryContract; // Address of the InsuranceFactory contract

    constructor(address _liquidityPoolAddress, address _owner, address _factoryContract) {
        owner = _owner;
        liquidityPool = InsuranceLiquidityPool(_liquidityPoolAddress);
        factoryContract = _factoryContract; // Store the address of the InsuranceFactory contract
    }

    modifier onlyInsuredOwner() {
        require(isOwnerInsuredByFactory(), "Owner is not insured by the factory");
        _;
    }

    function isOwnerInsuredByFactory() private view returns (bool) {
        InsuranceFactory factory = InsuranceFactory(factoryContract);
        uint length = factory.loanInsurancesLength(); // Get the length of the array

        for (uint i = 0; i < length; i++) {
            address insuranceAddress = factory.loanInsurances(i); // Accessing each element individually
            if (insuranceAddress == owner) {
                return true;
            }
        }
        return false;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function applyForInsurance(InsuranceType _insuranceType, uint256 _loanAmount, uint256 _coveragePercentage) public payable onlyInsuredOwner {
    require(!loanPolicies[msg.sender].active, "Already have a policy");
    uint256 premium = calculatePremium(_insuranceType, _loanAmount, _coveragePercentage);
    require(msg.value == premium, "Incorrect premium amount");

    // Send collected premiums to the liquidity pool, specifying the original sender
    liquidityPool.depositTo{value: msg.value}(msg.sender);

    loanPolicies[msg.sender] = LoanPolicy(_insuranceType, _loanAmount, premium, _coveragePercentage, true);
    emit InsuranceApplied(msg.sender, _insuranceType, _loanAmount, _coveragePercentage, premium);
}


    function calculatePremium(InsuranceType _insuranceType, uint256 _loanAmount, uint256 _coveragePercentage) private pure returns (uint256) {
        // Premium calculation based on insurance type
        if (_insuranceType == InsuranceType.Standard) {
            return _loanAmount * _coveragePercentage / 1000;
        } else {
            // Enhanced coverage may have a higher premium
            return _loanAmount * _coveragePercentage / 500;
        }
    }

   function claimInsurance() public onlyInsuredOwner {
    require(loanPolicies[msg.sender].active, "No active policy");
    uint256 payout = calculatePayout(msg.sender);
    emit PayoutAmountCalculated(msg.sender, payout);


    // Check if the liquidity pool has enough balance to cover the payout
    // This check assumes the liquidity pool contract has a method to check its Ether balance
    require(address(liquidityPool).balance >= payout, "Liquidity Pool has insufficient funds");

    // Withdraw the payout amount to the policyholder
    liquidityPool.withdraw(payout, msg.sender, payable(msg.sender));

    emit InsuranceClaimed(msg.sender, payout);

    // Deactivate the policy after the claim
    loanPolicies[msg.sender].active = false;
}


    function calculatePayout(address _policyHolder) public view returns (uint256) {
        // Payout calculation based on insurance type
        LoanPolicy storage policy = loanPolicies[_policyHolder];
        if (policy.insuranceType == InsuranceType.Standard) {
            return policy.loanAmount * policy.coveragePercentage / 100;
        } else {
            // Enhanced coverage may provide a higher payout
            return policy.loanAmount * policy.coveragePercentage * 150 / (100 * 100);
        }
    }
}
