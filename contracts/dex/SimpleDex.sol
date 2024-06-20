pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LiquidityToken.sol";

contract SimpleDex {
    mapping(address => mapping(address => address)) public lptokens;

    event PairCreated(address indexed token0, address indexed token1, address lptoken);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address to
    ) public returns (uint amountA, uint amountB, uint liquidity) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (uint amount0Desired, uint amount1Desired) = sortAmounts(tokenA, tokenB, amountADesired, amountBDesired);

        (address lptoken, uint amount0, uint amount1) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);

        liquidity = LiquidityToken(lptoken).mint(to);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        address to
    ) public returns (uint amountA, uint amountB) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address lptoken = lptokens[token0][token1];

        LiquidityToken(lptoken).transferFrom(msg.sender, lptoken, liquidity);

        (uint amount0, uint amount1) = LiquidityToken(lptoken).burn(to);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
    }

    function swap(
        uint amountIn,
        bool swapsTokenA,
        address tokenA,
        address tokenB,
        address to
    ) public returns (uint amountOut) {
        require(amountIn > 0, "failed");

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address lptoken = lptokens[token0][token1];

        {
            (uint reserve0, uint reserve1) = LiquidityToken(lptoken).getReserve();
            (uint reserseIn, uint reserveOut) = (tokenA == token0 && swapsTokenA) || (tokenA != token0 && !swapsTokenA) ? (reserve0, reserve1) : (reserve1, reserve0);

            uint amountInWithFee = amountIn * 997;
            amountOut = amountInWithFee * reserveOut / (reserseIn * 1000 + amountInWithFee);
        }

        if (swapsTokenA) IERC20(tokenA).transferFrom(msg.sender, lptoken, amountIn);
        else IERC20(tokenB).transferFrom(msg.sender, lptoken, amountIn);

        (uint amountAOut, uint amountBOut) = swapsTokenA ? (uint(0), amountOut): (amountOut, uint(0));
        (uint amount0Out, uint amount1Out) = sortAmounts(tokenA, tokenB, amountAOut, amountBOut);
        LiquidityToken(lptoken).swap(amount0Out, amount1Out, to);
    } 

    function createPair(address token0, address token1) internal returns (address lptoken) {
        require(lptokens[token0][token1] == address(0), "exist");
        
        bytes memory bytecode = type(LiquidityToken).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            lptoken:= create2(0, add(bytecode,32), mload(bytecode), salt)
        }

        LiquidityToken(lptoken).initialize(token0, token1);
        lptokens[token0][token1] = lptoken;

        emit PairCreated(token0, token1, lptoken);
    }

    function _addLiquidity(
        address token0,
        address token1,
        uint amount0Desired,
        uint amount1Desired
    ) private returns (address lptoken, uint amount0, uint amount1) {
        lptoken = lptokens[token0][token1];

        if (lptoken == address(0)) {
            lptoken = createPair(token0, token1);
        }

        (uint reserve0, uint reserve1) = LiquidityToken(lptoken).getReserve();

        if (reserve0 == 0 && reserve1 == 0) {
            (amount0, amount1) = (amount0Desired, amount1Desired);
        } else if (amount0Desired > 0) {
            amount0 = amount0Desired;
            amount1 = amount0 * reserve1 / reserve0;
        } else if (amount1Desired > 0) {
            amount1 = amount1Desired;
            amount0 = amount1 * reserve0 / reserve1;
        } else {
            revert("failed");
        }


        IERC20(token0).transferFrom(msg.sender, lptoken, amount0);

        IERC20(token1).transferFrom(msg.sender, lptoken, amount1);
    }

    function sortAmounts(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) internal pure returns (uint amount0, uint amount1) {
        require(amountA > 0 || amountB > 0, "either amount is zero");
        (amount0, amount1) = tokenA < tokenB ? (amountA, amountB) : (amountB, amountA);
    }

    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA!=tokenB, "both tokens are same address");

        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(token0 != address(0), "one of token is zero address");
    }
}


