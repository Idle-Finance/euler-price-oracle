// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import {ChainlinkOracle} from "src/adapter/chainlink/ChainlinkOracle.sol";
import {Errors} from "src/lib/Errors.sol";
import {OracleDescription} from "src/lib/OracleDescription.sol";

contract GovernedChainlinkOracle is ChainlinkOracle {
    event ConfigAdded(address indexed base, address indexed quote, address indexed feed);
    event ConfigRemoved(address indexed base, address indexed quote);

    constructor(address _feedRegistry, address _weth, address _owner) ChainlinkOracle(_feedRegistry, _weth) {}

    function addConfig(address base, address quote, address feed, uint32 maxStaleness, uint32 maxDuration, bool inverse)
        external
        onlyGovernor
    {
        bool isEnabled = feedRegistry.isFeedEnabled(feed);
        if (!isEnabled) revert Errors.Chainlink_FeedNotEnabled(feed);

        _setConfig(base, quote, feed, maxStaleness, maxDuration, inverse);

        emit ConfigAdded(base, quote, feed);
    }

    function removeConfig(address base, address quote) external onlyGovernor {
        delete configs[base][quote];
        delete configs[quote][base];

        emit ConfigRemoved(base, quote);
        emit ConfigRemoved(quote, base);
    }

    function description() external view returns (OracleDescription.Description memory) {
        return OracleDescription.GovernedChainlinkOracle(uint256(DEFAULT_MAX_STALENESS), governor);
    }
}
