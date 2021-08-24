pragma solidity >=0.8.0;
// import "./libraries/FoodcourtLibrary.sol";
import "./interfaces/router.sol";
import "./ownable.sol";
import "./interfaces/ERC20TOTHEMOON.sol";
// import "./libraries/TransferHelper.sol"

// interface IFoodcourt{
//     function swapExactTokensForTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);
// };

contract Swapper is Ownable{
    //function approve(address spender, uint256 amount) external returns (bool);
    function approveAddress(address spender,address token,uint amount) public onlyOwner {
        IERC20(token).approve(spender,amount);
    }
    //function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transferToContract(address _owner,address token,uint amount) private onlyOwner {
        IERC20(token).transferFrom(_owner,address(this),amount);
    }

    // function swapExactTokensForTokens(
    //     uint256 amountIn,
    //     uint256 amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     address router,
    //     uint256 deadline
    // ) external onlyOwner returns (uint256[] memory amounts){
    //     amounts = routerInterface(router).swapExactTokensForTokens(amountIn,amountOutMin, path, to, deadline );
    //     return amounts;
    // }
    
    function swapTothemoon(uint256 amountIn, address[][] calldata paths, address[] calldata routers, address to, uint256 deadline) external onlyOwner{
        uint256[] memory tempAmountOut;
        uint256[] memory amountOut = new uint[](routers.length);
        transferToContract(msg.sender,paths[0][0],amountIn);
        if(routers.length == 1){
            tempAmountOut = routerInterface(routers[0]).getAmountsOut(amountIn,paths[0]);
            amountOut[0] = tempAmountOut[tempAmountOut.length-1];
        }else{
        for (uint8 i; i < routers.length ; i++) {
            if (i == 0){
                tempAmountOut = routerInterface(routers[i]).getAmountsOut(amountIn,paths[i]);
                amountOut[i] = tempAmountOut[tempAmountOut.length-1];
            }else if(i > 0 && i < routers.length-1){
                tempAmountOut = routerInterface(routers[i]).getAmountsOut(amountOut[i-1],paths[i]);
                amountOut[i] = tempAmountOut[tempAmountOut.length-1];
            }else if(i == routers.length-1){
                tempAmountOut = routerInterface(routers[i]).getAmountsOut(amountOut[i-1],paths[i]);
                amountOut[i] = tempAmountOut[tempAmountOut.length-1];
            }
        }
        }
        require(amountOut[amountOut.length-1] > amountIn, "End balance must exceed start balance.");
        if(routers.length == 1){
            routerInterface(routers[0]).swapExactTokensForTokens(amountIn,amountOut[0], paths[0], to, deadline );
        }else{
        for (uint8 i; i < routers.length ; i++) {
        
            if (i == 0){
                routerInterface(routers[i]).swapExactTokensForTokens(amountIn,amountOut[i], paths[i], address(this), deadline );
            }else if(i > 0 && i < routers.length-1){
                routerInterface(routers[i]).swapExactTokensForTokens(amountOut[i-1],amountOut[i], paths[i], address(this), deadline );
            }else if(i == routers.length-1){
                routerInterface(routers[i]).swapExactTokensForTokens(amountOut[i-1],amountOut[i], paths[i], to, deadline );
            }
        }
        }
    }
}