// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IOFT, SendParam, MessagingFee, MessagingReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title RDATBridgeWrapper
 * @notice Wrapper contract for RDAT bridge with 0.01% burn fee mechanism
 * @dev Implements deflationary mechanics on cross-chain transfers
 */
contract RDATBridgeWrapper is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Constants
    uint256 public constant BURN_FEE_BPS = 1; // 0.01% = 1 basis point
    uint256 public constant BPS_DENOMINATOR = 10000;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // Immutable state
    IOFT public immutable oftAdapter;
    IERC20 public immutable rdatToken;

    // Mutable state
    uint256 public totalBurned;
    uint256 public totalBridged;
    uint256 public bridgeCount;

    // Fee recipient for any collected fees beyond burn
    address public feeRecipient;
    uint256 public protocolFeeBps; // Additional protocol fee if needed

    // Minimum and maximum bridge amounts
    uint256 public minBridgeAmount;
    uint256 public maxBridgeAmount;

    // Events
    event BridgeInitiated(
        address indexed sender,
        uint32 indexed dstEid,
        bytes32 indexed recipient,
        uint256 amountSent,
        uint256 amountBurned,
        uint256 amountBridged,
        bytes32 guid
    );

    event BurnFeeUpdated(uint256 oldFee, uint256 newFee);
    event MinMaxAmountUpdated(uint256 minAmount, uint256 maxAmount);
    event TotalBurnedUpdated(uint256 totalBurned);
    event EmergencyWithdraw(address token, uint256 amount);

    // Errors
    error AmountTooLow();
    error AmountTooHigh();
    error InsufficientFee();
    error TransferFailed();
    error InvalidRecipient();
    error InvalidDestination();

    /**
     * @notice Constructor
     * @param _oftAdapter Address of the OFT adapter contract
     * @param _rdatToken Address of the RDAT token
     * @param _minAmount Minimum bridge amount
     * @param _maxAmount Maximum bridge amount
     */
    constructor(
        address _oftAdapter,
        address _rdatToken,
        uint256 _minAmount,
        uint256 _maxAmount
    ) Ownable(msg.sender) {
        oftAdapter = IOFT(_oftAdapter);
        rdatToken = IERC20(_rdatToken);
        minBridgeAmount = _minAmount;
        maxBridgeAmount = _maxAmount;
        feeRecipient = msg.sender;
    }

    /**
     * @notice Bridge tokens with burn fee
     * @param _dstEid Destination endpoint ID
     * @param _to Recipient address on destination chain (bytes32 format)
     * @param _amountLD Amount to bridge in local decimals
     * @param _options Additional options for LayerZero
     * @param _slippageBps Allowed slippage in basis points
     */
    function bridgeWithBurn(
        uint32 _dstEid,
        bytes32 _to,
        uint256 _amountLD,
        bytes calldata _options,
        uint256 _slippageBps
    ) external payable whenNotPaused nonReentrant returns (bytes32 guid) {
        // Validate inputs
        if (_amountLD < minBridgeAmount) revert AmountTooLow();
        if (_amountLD > maxBridgeAmount) revert AmountTooHigh();
        if (_to == bytes32(0)) revert InvalidRecipient();
        if (_dstEid == 0) revert InvalidDestination();

        // Calculate fees
        uint256 burnAmount = (_amountLD * BURN_FEE_BPS) / BPS_DENOMINATOR;
        uint256 protocolFee = 0;
        if (protocolFeeBps > 0) {
            protocolFee = (_amountLD * protocolFeeBps) / BPS_DENOMINATOR;
        }
        uint256 bridgeAmount = _amountLD - burnAmount - protocolFee;

        // Transfer tokens from user
        rdatToken.safeTransferFrom(msg.sender, address(this), _amountLD);

        // Execute burn
        rdatToken.safeTransfer(BURN_ADDRESS, burnAmount);
        totalBurned += burnAmount;

        // Transfer protocol fee if applicable
        if (protocolFee > 0) {
            rdatToken.safeTransfer(feeRecipient, protocolFee);
        }

        // Approve OFT adapter
        rdatToken.safeApprove(address(oftAdapter), bridgeAmount);

        // Calculate minimum amount with slippage
        uint256 minAmountLD = bridgeAmount - ((bridgeAmount * _slippageBps) / BPS_DENOMINATOR);

        // Prepare send parameters
        SendParam memory sendParam = SendParam({
            dstEid: _dstEid,
            to: _to,
            amountLD: bridgeAmount,
            minAmountLD: minAmountLD,
            extraOptions: _options,
            composeMsg: "",
            oftCmd: ""
        });

        // Quote LayerZero fee
        MessagingFee memory fee = oftAdapter.quoteSend(sendParam, false);
        if (msg.value < fee.nativeFee) revert InsufficientFee();

        // Execute bridge
        MessagingReceipt memory receipt = oftAdapter.send{value: msg.value}(
            sendParam,
            fee,
            payable(msg.sender)
        );

        // Update statistics
        totalBridged += bridgeAmount;
        bridgeCount++;

        // Emit event
        emit BridgeInitiated(
            msg.sender,
            _dstEid,
            _to,
            _amountLD,
            burnAmount,
            bridgeAmount,
            receipt.guid
        );

        // Refund excess native fee
        if (msg.value > fee.nativeFee) {
            (bool success, ) = msg.sender.call{value: msg.value - fee.nativeFee}("");
            require(success, "Refund failed");
        }

        return receipt.guid;
    }

    /**
     * @notice Quote bridge fees
     * @param _dstEid Destination endpoint ID
     * @param _amountLD Amount to bridge
     * @param _options Additional options
     * @return nativeFee LayerZero fee in native token
     * @return burnAmount Amount to be burned
     * @return protocolFee Protocol fee amount
     * @return receiveAmount Amount user will receive
     */
    function quoteBridge(
        uint32 _dstEid,
        uint256 _amountLD,
        bytes calldata _options
    ) external view returns (
        uint256 nativeFee,
        uint256 burnAmount,
        uint256 protocolFee,
        uint256 receiveAmount
    ) {
        burnAmount = (_amountLD * BURN_FEE_BPS) / BPS_DENOMINATOR;
        if (protocolFeeBps > 0) {
            protocolFee = (_amountLD * protocolFeeBps) / BPS_DENOMINATOR;
        }
        receiveAmount = _amountLD - burnAmount - protocolFee;

        SendParam memory sendParam = SendParam({
            dstEid: _dstEid,
            to: bytes32(0),
            amountLD: receiveAmount,
            minAmountLD: (receiveAmount * 99) / 100,
            extraOptions: _options,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = oftAdapter.quoteSend(sendParam, false);
        nativeFee = fee.nativeFee;
    }

    /**
     * @notice Get bridge statistics
     */
    function getBridgeStats() external view returns (
        uint256 burned,
        uint256 bridged,
        uint256 count,
        uint256 avgBridge
    ) {
        burned = totalBurned;
        bridged = totalBridged;
        count = bridgeCount;
        avgBridge = count > 0 ? bridged / count : 0;
    }

    // Admin functions

    /**
     * @notice Update min/max bridge amounts
     */
    function updateBridgeLimits(
        uint256 _minAmount,
        uint256 _maxAmount
    ) external onlyOwner {
        require(_minAmount < _maxAmount, "Invalid limits");
        minBridgeAmount = _minAmount;
        maxBridgeAmount = _maxAmount;
        emit MinMaxAmountUpdated(_minAmount, _maxAmount);
    }

    /**
     * @notice Update protocol fee
     */
    function updateProtocolFee(uint256 _feeBps) external onlyOwner {
        require(_feeBps <= 100, "Fee too high"); // Max 1%
        protocolFeeBps = _feeBps;
    }

    /**
     * @notice Update fee recipient
     */
    function updateFeeRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "Invalid recipient");
        feeRecipient = _recipient;
    }

    /**
     * @notice Pause bridge
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause bridge
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Emergency withdraw tokens
     */
    function emergencyWithdraw(
        address _token,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_token).safeTransfer(owner(), _amount);
        emit EmergencyWithdraw(_token, _amount);
    }

    /**
     * @notice Receive native token
     */
    receive() external payable {}
}