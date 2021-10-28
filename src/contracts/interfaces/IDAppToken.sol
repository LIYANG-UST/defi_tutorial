// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**@title  DappToken
 * @notice This token has an owner and a minter.
 *         By default, the owner & minter account will be the one that deploys the contract.
 */
interface IDAppToken is IERC20 {
    event MinterChanged(address _oldMinter, address _newMinter);
    event OwnerChanged(address _oldOwner, address _newOwner);
    event OwnershipReleased(address _oldOwner);

    // ---------------------------------------------------------------------------------------- //
    // ******************************* External/Public Functions ****************************** //
    // ---------------------------------------------------------------------------------------- //

    /**
     * @notice Pass the minter role to a new address, only the owner can change the minter !!!
     * @param _newMinter: New minter's address
     * @return Whether the minter has been changed
     */
    function passMinterRole(address _newMinter) external returns (bool);

    /**
     * @notice Pass the owner role to a new address, only the owner can change the owner !!!
     * @param _newOwner: New owner's address
     * @return Whether the owner has been changed
     */
    function passOwnership(address _newOwner) external returns (bool);

    /**
     * @notice Release the ownership to zero address, can never get back !!!
     * @return Whether the ownership has been released
     */
    function releaseOwnership() external returns (bool);

    /**
     * @notice Mint tokens
     * @param _account: Receiver's address
     * @param _amount: Amount to be minted
     */
    function mint(address _account, uint256 _amount) external;
}
