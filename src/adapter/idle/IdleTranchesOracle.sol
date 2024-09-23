// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {BaseAdapter, Errors, IPriceOracle} from "../BaseAdapter.sol";
import {ScaleUtils, Scale} from "../../lib/ScaleUtils.sol";
import {IIdleCDO} from "./IIdleCDO.sol";

/// @title IdleTranchesOracle
/// @custom:security-contact security@euler.xyz
/// @author Idle DAO (https://idle.finance)
/// @notice Adapter for pricing Idle tranches to their respective underlyings.
contract IdleTranchesOracle is BaseAdapter {
  /// @inheritdoc IPriceOracle
  /// @notice General description of this oracle implementation.
  string public constant name = "IdleTranchesOracle";
  /// @notice The address of the base asset.
  address public immutable underlying;
  /// @notice The address of the CDO contract.
  address public immutable cdo;
  /// @notice The address of the tranche contract.
  address public immutable tranche;
  /// @notice The scale factors used for decimal conversions.
  Scale internal immutable scale;

  /// @param _cdo The address of the CDO contract.
  /// @param _tranche The address of the tranche contract.
  constructor(address _cdo, address _tranche) {
    cdo = _cdo;
    tranche = _tranche;
    underlying = IIdleCDO(_cdo).token();
    uint8 baseDecimals = _getDecimals(_tranche);
    uint8 quoteDecimals = _getDecimals(underlying);
    // IdleCDO returns a value with `underlyings` decimals.
    scale = ScaleUtils.calcScale(baseDecimals, quoteDecimals, quoteDecimals);
  }

  function _getQuote(uint256 inAmount, address _base, address _quote) internal view override returns (uint256) {
    bool inverse = ScaleUtils.getDirectionOrRevert(_base, tranche, _quote, underlying);
    uint256 rate = IIdleCDO(cdo).virtualPrice(tranche);
    if (rate == 0) revert Errors.PriceOracle_InvalidAnswer();
    return ScaleUtils.calcOutAmount(inAmount, rate, scale, inverse);
  }
}