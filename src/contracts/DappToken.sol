// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IDAppToken.sol";

/**@title  DappToken
 * @notice This token has an owner and a minter.
 *         By default, the owner & minter account will be the one that deploys the contract.
 */
contract DAppToken is ERC20, IDAppToken {
    // ---------------------------------------------------------------------------------------- //
    // ************************************ State Variables *********************************** //
    // ---------------------------------------------------------------------------------------- //

    address public owner;
    address minter;

    // ---------------------------------------------------------------------------------------- //
    // ************************************** Constructor ************************************* //
    // ---------------------------------------------------------------------------------------- //

    constructor() ERC20("DAppToken", "DAP") {
        owner = msg.sender;
        minter = msg.sender;
    }

    // ---------------------------------------------------------------------------------------- //
    // *************************************** Modifiers ************************************** //
    // ---------------------------------------------------------------------------------------- //

    /// @notice Only the owner can call some functions.
    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function!");
        _;
    }

    /// @notice Can not set some addresses to zero.
    modifier isValidAddress(address _address) {
        require(_address != address(0), "Can not use zero address!");
        _;
    }

    // ---------------------------------------------------------------------------------------- //
    // ******************************* External/Public Functions ****************************** //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Pass the minter role to a new address, only the owner can change the minter !!!
     * @param _newMinter: New minter's address
     * @return Whether the minter has been changed
     */
    function passMinterRole(address _newMinter)
        public
        override
        onlyOwner
        isValidAddress(_newMinter)
        returns (bool)
    {
        _setMinter(_newMinter);

        emit MinterChanged(msg.sender, _newMinter);
        return true;
    }

    /**
     * @notice Pass the owner role to a new address, only the owner can change the owner !!!
     * @param _newOwner: New owner's address
     * @return Whether the owner has been changed
     */
    function passOwnership(address _newOwner)
        public
        override
        onlyOwner
        isValidAddress(_newOwner)
        returns (bool)
    {
        owner = _newOwner;

        emit OwnerChanged(msg.sender, _newOwner);
        return true;
    }

    /**
     * @notice Release the ownership to zero address, can never get back !!!
     * @return Whether the ownership has been released
     */
    function releaseOwnership() public override onlyOwner returns (bool) {
        owner = address(0);

        emit OwnershipReleased(msg.sender);
        return true;
    }

    /**
     * @notice Mint tokens
     * @param _account: Receiver's address
     * @param _amount: Amount to be minted
     */
    function mint(address _account, uint256 _amount) public override {
        require(msg.sender == minter, "Error! Msg.sender must be the minter");

        _mint(_account, _amount); // ERC20 method with an event
    }

    // ---------------------------------------------------------------------------------------- //
    // *********************************** Internal Functions ********************************* //
    // ---------------------------------------------------------------------------------------- //

    function _setMinter(address _newMinter) internal {
        minter = _newMinter;
    }
}
