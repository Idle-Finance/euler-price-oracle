// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {EOracleGovPropTest} from "test/prop/EOracleGov.prop.t.sol";
import {ChainlinkOracle} from "src/adapter/chainlink/ChainlinkOracle.sol";

contract ChainlinkOracleGov_PropTest is EOracleGovPropTest {
    address GOVERNOR = makeAddr("GOVERNOR");
    address CHAINLINK_FEED_REGISTRY = makeAddr("CHAINLINK_FEED_REGISTRY");
    address WETH = makeAddr("WETH");

    function _deployOracle() internal override returns (address) {
        return address(new ChainlinkOracle(CHAINLINK_FEED_REGISTRY, WETH));
    }

    function _govMethods() internal pure override returns (bytes4[] memory) {
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = ChainlinkOracle.govSetConfig.selector;
        selectors[1] = ChainlinkOracle.govUnsetConfig.selector;
        return selectors;
    }
}
