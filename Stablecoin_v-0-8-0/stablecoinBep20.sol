// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// Kontrak Stablecoin yang Ditingkatkan
contract UpgradedStableCoin is ERC20, AccessControl, Pausable {
    
    // 1. Definisikan Peran (Roles)
    // ROLE DEFAULT: Beri peran ini kepada alamat yang akan menjadi administrator atau MultiSig.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); 
    // ROLE MINTER: Hanya yang memiliki peran ini yang bisa mencetak token baru.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // ROLE PAUSER: Hanya yang memiliki peran ini yang bisa menghentikan transfer.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(uint256 initialSupply) 
        ERC20("USD Coin BEP20 Upgraded", "USDC_U") 
    {
        // Tetapkan Deployer (msg.sender) sebagai Admin default
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        // Beri Deployer peran MINTER dan PAUSER
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        
        // Cetak pasokan awal ke deployer
        _mint(msg.sender, initialSupply);
    }
    
    // --- 2. Kontrol Transfer dengan Pausable ---
    
    // Fungsi transfer akan memanggil 'whenNotPaused' secara otomatis
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }
    
    // Fungsi untuk menghentikan kontrak (hanya dapat dipanggil oleh yang memiliki PAUSER_ROLE)
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }
    
    // Fungsi untuk melanjutkan kontrak (hanya dapat dipanggil oleh yang memiliki PAUSER_ROLE)
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // --- 3. Fungsi Mint & Burn yang Terkontrol (Role-Based) ---
    
    // Fungsi untuk mencetak token baru
    // HANYA DAPAT DIPANGGIL OLEH YANG MEMILIKI MINTER_ROLE
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        // Logika batasan pencetakan harian (jika diterapkan) diletakkan di sini
        _mint(to, amount);
    }

    // Fungsi untuk membakar token yang ada
    // HANYA DAPAT DIPANGGIL OLEH YANG MEMILIKI MINTER_ROLE
    function burn(uint256 amount) public onlyRole(MINTER_ROLE) {
        _burn(msg.sender, amount);
    }
}
