// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {BaseOracle} from "src/BaseOracle.sol";
import {IEOracle} from "src/interfaces/IEOracle.sol";
import {Errors} from "src/lib/Errors.sol";
import {OracleDescription} from "src/lib/OracleDescription.sol";
import {TryCallOracle} from "src/strategy/TryCallOracle.sol";

/// @author totomanov
/// @notice Reduce an array of quotes by applying a statistical function.
abstract contract Aggregator is BaseOracle, TryCallOracle {
    uint256 public quorum;
    address[] public oracles;

    constructor(address[] memory _oracles, uint256 _quorum) {
        uint256 cardinality = _oracles.length;
        if (cardinality == 0) revert Errors.Aggregator_OraclesEmpty();
        if (_quorum == 0) revert Errors.Aggregator_QuorumZero();
        if (_quorum > cardinality) revert Errors.Aggregator_QuorumTooLarge(_quorum, cardinality);
        quorum = _quorum;

        oracles = new address[](cardinality);
        for (uint256 i = 0; i < cardinality;) {
            oracles[i] = _oracles[i];
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IEOracle
    function getQuote(uint256 inAmount, address base, address quote) external view returns (uint256) {
        return _getQuote(inAmount, base, quote);
    }

    /// @inheritdoc IEOracle
    function getQuotes(uint256 inAmount, address base, address quote) external view returns (uint256, uint256) {
        uint256 answer = _getQuote(inAmount, base, quote);
        return (answer, answer);
    }

    /// @inheritdoc IEOracle
    function description() external pure virtual returns (OracleDescription.Description memory);

    /// @dev Apply the aggregation algorithm.
    function _aggregateQuotes(uint256[] memory) internal view virtual returns (uint256);

    function _getQuote(uint256 inAmount, address base, address quote) private view returns (uint256) {
        uint256 cardinality = oracles.length;
        uint256[] memory answers = new uint256[](cardinality);
        uint256 numAnswers;

        for (uint256 i = 0; i < cardinality;) {
            IEOracle oracle = IEOracle(oracles[i]);
            (bool success, uint256 answer) = _tryGetQuote(oracle, inAmount, base, quote);

            unchecked {
                if (success) {
                    answers[numAnswers] = answer;
                    ++numAnswers;
                }
                ++i;
            }
        }

        if (numAnswers < quorum) revert Errors.Aggregator_QuorumNotReached(numAnswers, quorum);

        assembly {
            // update the length of answer
            // this is safe because new length <= initial length
            mstore(answers, numAnswers)
        }

        // custom aggregation logic here
        return _aggregateQuotes(answers);
    }
}
