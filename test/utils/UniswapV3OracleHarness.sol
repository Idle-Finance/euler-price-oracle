// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {UniswapV3Config} from "src/uniswap/UniswapV3Config.sol";
import {UniswapV3Oracle} from "src/uniswap/UniswapV3Oracle.sol";

contract UniswapV3OracleHarness is UniswapV3Oracle {
    constructor(address _uniswapV3Factory) UniswapV3Oracle(_uniswapV3Factory) {}

    function getConfig(address base, address quote) external view returns (UniswapV3Config) {
        return _getConfig(base, quote);
    }

    function getOrRevertConfig(address base, address quote) external view returns (UniswapV3Config) {
        return _getOrRevertConfig(base, quote);
    }

    function setConfig(address token0, address token1, address pool, uint32 validUntil, uint24 fee, uint24 twapWindow)
        external
        returns (UniswapV3Config)
    {
        return _setConfig(token0, token1, pool, validUntil, fee, twapWindow);
    }

    function sortTokens(address tokenA, address tokenB) external pure returns (address, address) {
        return _sortTokens(tokenA, tokenB);
    }
}
