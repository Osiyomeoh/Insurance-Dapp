// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./CryptoWallet.sol";
import "./Collateral.sol";

contract InsuranceFactory {
    address[]  public walletInsurances;
    address[] public loanInsurances;

     function createCryptoWalletInsurance(address _liquidityPoolAddress, address _owner, address _factoryContract) public {
        // Create a new CryptoWalletInsurance instance with the specified owner
        CryptoWalletInsurance newWalletInsurance = new CryptoWalletInsurance(_liquidityPoolAddress, _owner, _factoryContract);
        walletInsurances.push(address(newWalletInsurance));
    }

    function createCollateralLoanInsurance(address _liquidityPoolAddress, address _owner, address _factoryContract) public {
        CollateralLoanInsurance newLoanInsurance = new CollateralLoanInsurance(_liquidityPoolAddress, _owner, _factoryContract);
        loanInsurances.push(address(newLoanInsurance));
    }

   function walletInsurancesLength() public view returns (uint) {
        return walletInsurances.length;
    }
    function loanInsurancesLength() public view returns (uint) {
        return loanInsurances.length;
    }
}
