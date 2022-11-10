//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import {ERC20} from "./erc20.sol";
import {DepositorCoin} from "./depositorcoin.sol";
import {oracle} from "./oracle.sol";
import {WadLib} from "./WadLib.sol";

contract stablecoin is ERC20{
    using WadLib for uint256;

    error InitialCollateralRatioError(string message, uint256 minimumDepositAmount);

    
    DepositorCoin public depositorCoin;
    Oracle public oracle;

  
    uint256 public feeRatePercentage;
    uint256 public constant iNITIAL_COLLATERAL_RATIO_PERCENTAGE = 10;

    constructor(uint256 _feeOPercentage, Oracle _oracle) ERC20("stablecoin", "STC"){
        feeRatePercentage = _feeRatePercentage;
        oracle = _oracle;
    }

    function mint() external payable {
        uint256 fee = _getFee(msg.value);
        uint256 remainingEth = msg.value - fee;
        uint256 mintStablecoinAmount = remainingEth * oracle.getPrice();
        _mint(msg.sender, mintStablecoinAmount);
    }

    function burn(uint256 burnStablecoinAmount) external{
        int256 deficitOrSurplusInUsd = _getDeficitOfSurplusInContractInUsd();
        require(deficitOrSurplusInUsd >= 0, "STC NOT BURNED WHILE IN DEFICIT");
        _burn(msg.sender,burnStableCoinAmount);

        uint256 refundingEth = burnStablecoinAmount / oracle.getPrice();
        uint256 fee = _getFee(refundingEth);
        uint256 remainingRefundingEth = refundingEth - fee;

        (bool success,) = msg.sender.call{value: remainingRefundingEth}("");
        require(success, "STC: BURN REFUND TRANSACTION FAILED");
    }

    function _getFee(uint256 ethAmount) private view returns (uint256){
        bool hasDepositors = address(DepositorCoin) != address(0) && DepositorCoin.totalSupply() > 0;
        if (!hasDepositors){
            return 0;
        }
        
        return (feeRatePercentage * ethAmount) / 100;
    }

    function depositCollateralBuffer() external payable{
        int256 deficitOrSurplusInUsd = _getDeficitOfSurplusInContractInUsd();

        if(deficitOrSurplusInUsd <= 0){
            uint256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1);
            uint256 usdInEthPrice = oracle.getPrice();
            uint256 deficitInEth = deficitInUsd / usdInEthPrice;

            uint256 requiredInitialSurplusInUsd = (INITIAL_COLLATERAL_RATIO_PERCENTAGE * totalSupply) /100;
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / usdInEthPrice;

            if ( msg.value < deficitInEth + requiredInitialSurplusInEth){
                uint256 minimumDepositAmount = deficitInEth + requiredInitialSurplusInEth;
                revert InitialCollateralRatioError("STC: Initial collatera ratio not met, minimum is: ",minimumDepositAmount);

            uint256 newInitialSurplusInEth = msg.value - deficitInEth;
            uint256 newInitialSurplusInUsd = newInitialSurplusInEth * usdInEthPrice;

            depositorCoin = new DepositorCoin();
            uint256 mintDepositorCoinAmount = newInitialSurplusInUsd;
            depositorCoin.mint(msg.sender, mintDepositorCoinAmount);

            return ;
        

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        WadLib.Wad dpcInUsdPrice =_getdpcInUsdPrice(surplusInUsd);
        uint256 mintDepositorCoinAmount = ((msg.value.mulWad (dpcInUsdPrice))
         / oracle.getPrice());

        depositorCoin.mint(msg.sender,mintDepositorCoinAmount);
    
    }

        function  withdrawCollateralBuffer(uint256 burnDepositorCoinAmount)
            external
     {
       require (depositorCoin.balanceOf(msg.sender) >= ,
        "STC: SENDER HAS INSUFICIENT DPC FUNDS"
       );
       
        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        int256 deficitOrSurplusInUsd = _getDeficitOfSurplusInContractInUsd();
        require (deficitInUsd > 0,"STC NO FUNDS TO WITHDWA");

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        WadLib.Wad dpcInUsdPrice = _getdpcInUsdPrice(surplusInUsd);
        uint256 refundingInUsd = burnDepositorCoinAmount.mulWad(dpcInUsdPrice);
        uint256 refundingEth = refundingInUsd oracle.getPrice();

        (bool success,) = msg.sender.call{value: refundingEth}("");
        require(success,"stc:refund transaction failed");
        }
    

    function _getDeficitOfSurplusInContractInUsd() private view returns(int256){
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) * oracle.getPrice();
        uint256 totalStablecoinBalanceInUsd = totalSupply;
        int256 deficitOrSurplus = int256(ethContractBalanceInUsd) - int256(totalStablecoinBalanceInUsd);

        return deficitOrSurplus;
    }

    function _getdpcInUsdPrice(uint256 surplusInUsd) private view returns(uint256){

       return (Wadlib.wad);
    {
     return WadLib.fromFraction(depositorCoin.totalSupply(),surplusInUsd);
    }


    

}