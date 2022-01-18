// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

interface IERC20 {
    function balanceOf(address _account) external view returns (uint256);

    function transfer(address _recipient, uint256 _amount) external;
}

interface IPair is IERC20 {
    function token0() external returns (IERC20);

    function token1() external returns (IERC20);

    function burn(address _to) external;
}

/// @title LP Hunter
/// @author HHK
/// @notice Small contract to burn LPs sent to LP contract itself against a small fee
contract LpHunter {
    error NotOwner();

    address public owner;
    uint256 public tip;

    constructor(address _owner, uint256 _tip) {
        owner = _owner;
        tip = _tip;
    }

    /// @notice Burn LPs and send back tokens to victim minus a small tip
    /// @param _target The LP address to interact with
    /// @param _victim The victim address to send back tokens to
    function shoot(IPair _target, address _victim) public {
        IERC20 tokenA = _target.token0();
        IERC20 tokenB = _target.token1();
        _target.burn(address(this));
        tokenA.transfer(owner, tokenA.balanceOf(address(this)) / tip);
        tokenA.transfer(_victim, tokenA.balanceOf(address(this)));
        tokenB.transfer(owner, tokenB.balanceOf(address(this)) / tip);
        tokenB.transfer(_victim, tokenB.balanceOf(address(this)));
    }

    /// @notice Check LPs available to burn
    /// @param _targets Array of LP
    /// @return amounts Array of LP amount burnable
    function hunt(IPair[] calldata _targets)
        public
        view
        returns (uint256[] memory amounts)
    {
        amounts = new uint256[](_targets.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            IPair target = _targets[i];
            amounts[i] = target.balanceOf(address(target));
        }
        return amounts;
    }

    /// @notice Update the tip percentage
    /// @param _newTip New tip percentage
    function updateTip(uint256 _newTip) public {
        if (msg.sender != owner) revert NotOwner();
        tip = _newTip;
    }

    /// @notice Update the owner of the contract
    /// @param _newOwner New owner of the contract
    function transferOwnership(address _newOwner) public {
        if (msg.sender != owner) revert NotOwner();
        owner = _newOwner;
    }
}
