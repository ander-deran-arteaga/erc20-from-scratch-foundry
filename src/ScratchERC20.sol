// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyHelloToken {
    // metadata
    string public name;
    string public symbol;
    uint8 public immutable decimals;

    // ERC20
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // admin / config (packed)
    address public owner;
    address public feeRecipient;
    uint16 public feeBps; // 0..10000
    bool public paused;

    uint256 internal constant BPS_DENOM = 10_000;
    uint16 internal constant MAX_FEE_BPS = 1_000;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address indexed by);
    event Unpaused(address indexed by);

    error ZeroAddress();
    error NotOwner();
    error PausedErr();
    error InvalidFee();
    error InsufficientBalance();
    error InsufficientAllowance();
    error AlreadyPaused();
    error AlreadyUnpaused();

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        _mint(msg.sender, 1000 * (10 ** _decimals)); // optional
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    modifier whenNotPaused() {
        if (paused) {
            revert PausedErr();
        }
        _;
    }

    function setFeeConfig(address _feeRecipient, uint16 _feeBps) external onlyOwner {
        if (_feeBps > MAX_FEE_BPS) {
            revert InvalidFee();
        }
        if (_feeBps != 0 && _feeRecipient == address(0)) {
            revert ZeroAddress();
        }
        feeRecipient = _feeRecipient;
        feeBps = _feeBps;
    }

    function transfer(address to, uint256 amount) external whenNotPaused returns (bool) {
        _transferWithFee(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external whenNotPaused returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transferWithFee(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) {
            revert ZeroAddress();
        }
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 added) external returns (bool) {
        if (spender == address(0)) {
            revert ZeroAddress();
        }
        uint256 cur = allowance[msg.sender][spender];
        uint256 next = cur + added;
        allowance[msg.sender][spender] = next;
        emit Approval(msg.sender, spender, next);
        return true;
    }

    function decreaseAllowance(address spender, uint256 sub) external returns (bool) {
        if (spender == address(0)) {
            revert ZeroAddress();
        }
        uint256 cur = allowance[msg.sender][spender];
        if (cur < sub) {
            revert InsufficientAllowance();
        }
        unchecked {
            uint256 next = cur - sub;
            allowance[msg.sender][spender] = next;
            emit Approval(msg.sender, spender, next);
        }
        return true;
    }

    function pause() external onlyOwner {
        if (paused) {
            revert AlreadyPaused();
        }
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        if (!paused) {
            revert AlreadyUnpaused();
        }
        paused = false;
        emit Unpaused(msg.sender);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }
        owner = newOwner;
    }

    // ---------------- internals ----------------

    function _spendAllowance(address from, address spender, uint256 amount) internal {
        uint256 allowed = allowance[from][spender];
        if (allowed != type(uint256).max) {
            if (allowed < amount) {
                revert InsufficientAllowance();
            }
            unchecked {
                allowance[from][spender] = allowed - amount;
            }
        }
    }

    function _transferWithFee(address from, address to, uint256 amount) internal {
        if (from == address(0) || to == address(0)) {
            revert ZeroAddress();
        }

        uint256 fromBal = balanceOf[from];
        if (fromBal < amount) {
            revert InsufficientBalance();
        }

        uint256 fee = 0;
        uint16 bps = feeBps;
        if (bps != 0) {
            // invariant: feeRecipient != 0 when bps != 0 (enforced in setFeeConfig)
            // NOTE: mul overflow edge case discussed above
            fee = (amount * uint256(bps)) / BPS_DENOM;
        }

        unchecked {
            balanceOf[from] = fromBal - amount;

            uint256 sendAmount = amount - fee;
            balanceOf[to] += sendAmount;
            emit Transfer(from, to, sendAmount);

            if (fee != 0) {
                address fr = feeRecipient;
                balanceOf[fr] += fee;
                emit Transfer(from, fr, fee);
            }
        }
    }

    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) {
            revert ZeroAddress();
        }
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        if (from == address(0)) {
            revert ZeroAddress();
        }
        uint256 bal = balanceOf[from];
        if (bal < amount) {
            revert InsufficientBalance();
        }
        unchecked {
            balanceOf[from] = bal - amount;
        }
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}
