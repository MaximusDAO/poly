// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// Contract Interfaces and Abstract contracts
    // this interface comes directly from the Icosa contract. Many of these are not used in Poly Maximus
    // https://etherscan.io/token/0x3819f64f282bf135d62168c1e513280daf905e06#code
    interface HedronContract {
        struct LiquidationStore{
            uint256 liquidationStart;
            address hsiAddress;
            uint96  bidAmount;
            address liquidator;
            uint88  endOffset;
            bool    isActive;
        }
        struct HEXStakeMinimal {
        uint40 stakeId;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        }
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
        event Claim(uint256 data, address indexed claimant, uint40 indexed stakeId);
        event LoanEnd(
            uint256 data,
            address indexed borrower,
            uint40 indexed stakeId
        );
        event LoanLiquidateBid(
            uint256 data,
            address indexed bidder,
            uint40 indexed stakeId,
            uint40 indexed liquidationId
        );
        event LoanLiquidateExit(
            uint256 data,
            address indexed liquidator,
            uint40 indexed stakeId,
            uint40 indexed liquidationId
        );
        event LoanLiquidateStart(
            uint256 data,
            address indexed borrower,
            uint40 indexed stakeId,
            uint40 indexed liquidationId
        );
        event LoanPayment(
            uint256 data,
            address indexed borrower,
            uint40 indexed stakeId
        );
        event LoanStart(
            uint256 data,
            address indexed borrower,
            uint40 indexed stakeId
        );
        event Mint(uint256 data, address indexed minter, uint40 indexed stakeId);
        event Transfer(address indexed from, address indexed to, uint256 value);

        function allowance(address owner, address spender)
            external
            view
            returns (uint256);

        function approve(address spender, uint256 amount) external returns (bool);

        function balanceOf(address account) external view returns (uint256);

        function calcLoanPayment(
            address borrower,
            uint256 hsiIndex,
            address hsiAddress
        ) external view returns (uint256, uint256);

        function calcLoanPayoff(
            address borrower,
            uint256 hsiIndex,
            address hsiAddress
        ) external view returns (uint256, uint256);

        function claimInstanced(
            uint256 hsiIndex,
            address hsiAddress,
            address hsiStarterAddress
        ) external;

        function claimNative(uint256 stakeIndex, uint40 stakeId)
            external
            returns (uint256);

        function currentDay() external view returns (uint256);

        function dailyDataList(uint256)
            external
            view
            returns (
                uint72 dayMintedTotal,
                uint72 dayLoanedTotal,
                uint72 dayBurntTotal,
                uint32 dayInterestRate,
                uint8 dayMintMultiplier
            );

        function decimals() external view returns (uint8);

        function decreaseAllowance(address spender, uint256 subtractedValue)
            external
            returns (bool);

        function hsim() external view returns (address);

        function increaseAllowance(address spender, uint256 addedValue)
            external
            returns (bool);

        function liquidationList(uint256)
            external
            view
            returns (LiquidationStore memory);
            /*
            returns (
                uint256 liquidationStart,
                address hsiAddress,
                uint96 bidAmount,
                address liquidator,
                uint88 endOffset,
                bool isActive
            );*/

        function loanInstanced(uint256 hsiIndex, address hsiAddress)
            external
            returns (uint256);

        function loanLiquidate(
            address owner,
            uint256 hsiIndex,
            address hsiAddress
        ) external returns (uint256);

        function loanLiquidateBid(uint256 liquidationId, uint256 liquidationBid)
            external
            returns (uint256);

        function loanLiquidateExit(uint256 hsiIndex, uint256 liquidationId)
            external
            returns (address);

        function loanPayment(uint256 hsiIndex, address hsiAddress)
            external
            returns (uint256);

        function loanPayoff(uint256 hsiIndex, address hsiAddress)
            external
            returns (uint256);

        function loanedSupply() external view returns (uint256);

        function mintInstanced(uint256 hsiIndex, address hsiAddress)
            external
            returns (uint256);

        function mintNative(uint256 stakeIndex, uint40 stakeId)
            external
            returns (uint256);

        function name() external view returns (string memory);

        function proofOfBenevolence(uint256 amount) external;

        function shareList(uint256)
            external
            view
            returns (
                HEXStakeMinimal memory stake,
                uint16 mintedDays,
                uint8 launchBonus,
                uint16 loanStart,
                uint16 loanedDays,
                uint32 interestRate,
                uint8 paymentsMade,
                bool isLoaned
            );

        function symbol() external view returns (string memory);

        function totalSupply() external view returns (uint256);

        function transfer(address recipient, uint256 amount)
            external
            returns (bool);

        function transferFrom(
            address sender,
            address recipient,
            uint256 amount
        ) external returns (bool);
    }
    // this comes from the icosa contract. Used for staking HDRN
    // https://etherscan.io/token/0xfc4913214444af5c715cc9f7b52655e788a569ed#code
    interface IcosaInterface {
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
        event HDRNStakeAddCapital(uint256 data, address indexed staker);
        event HDRNStakeEnd(uint256 data, address indexed staker);
        event HDRNStakeStart(uint256 data, address indexed staker);
        event HDRNStakingStats(
            uint256 data,
            uint256 payout,
            uint256 indexed stakeDay
        );
        event HSIBuyBack(
            uint256 price,
            address indexed seller,
            uint40 indexed stakeId
        );
        event ICSAStakeAddCapital(uint256 data, address indexed staker);
        event ICSAStakeEnd(uint256 data0, uint256 data1, address indexed staker);
        event ICSAStakeStart(uint256 data, address indexed staker);
        event ICSAStakingStats(
            uint256 data,
            uint256 payoutIcsa,
            uint256 payoutHdrn,
            uint256 indexed stakeDay
        );
        event NFTStakeEnd(
            uint256 data,
            address indexed staker,
            uint96 indexed nftId
        );
        event NFTStakeStart(
            uint256 data,
            address indexed staker,
            uint96 indexed nftId,
            address indexed tokenAddress
        );
        event NFTStakingStats(
            uint256 data,
            uint256 payout,
            uint256 indexed stakeDay
        );
        event Transfer(address indexed from, address indexed to, uint256 value);

        function allowance(address owner, address spender)
            external
            view
            returns (uint256);

        function approve(address spender, uint256 amount) external returns (bool);

        function balanceOf(address account) external view returns (uint256);

        function currentDay() external view returns (uint256);

        function decimals() external view returns (uint8);

        function decreaseAllowance(address spender, uint256 subtractedValue)
            external
            returns (bool);

        function hdrnPoolIcsaCollected() external view returns (uint256);

        function hdrnPoolPayout(uint256) external view returns (uint256);

        function hdrnPoolPoints(uint256) external view returns (uint256);

        function hdrnPoolPointsRemoved() external view returns (uint256);

        function hdrnSeedLiquidity(uint256) external view returns (uint256);

        function hdrnStakeAddCapital(uint256 amount) external returns (uint256);

        function hdrnStakeEnd()
            external
            returns (
                uint256,
                uint256,
                uint256
            );

        function hdrnStakeStart(uint256 amount) external returns (uint256);

        function hdrnStakes(address)
            external
            view
            returns (
                uint64 stakeStart,
                uint64 capitalAdded,
                uint120 stakePoints,
                bool isActive,
                uint80 payoutPreCapitalAddIcsa,
                uint80 payoutPreCapitalAddHdrn,
                uint80 stakeAmount,
                uint16 minStakeLength
            );

        function hexStakeSell(uint256 tokenId) external returns (uint256);

        function icsaPoolHdrnCollected() external view returns (uint256);

        function icsaPoolIcsaCollected() external view returns (uint256);

        function icsaPoolPayoutHdrn(uint256) external view returns (uint256);

        function icsaPoolPayoutIcsa(uint256) external view returns (uint256);

        function icsaPoolPoints(uint256) external view returns (uint256);

        function icsaPoolPointsRemoved() external view returns (uint256);

        function icsaSeedLiquidity(uint256) external view returns (uint256);

        function icsaStakeAddCapital(uint256 amount) external returns (uint256);

        function icsaStakeEnd()
            external
            returns (
                uint256,
                uint256,
                uint256,
                uint256,
                uint256
            );

        function icsaStakeStart(uint256 amount) external returns (uint256);

        function icsaStakedSupply() external view returns (uint256);

        function icsaStakes(address)
            external
            view
            returns (
                uint64 stakeStart,
                uint64 capitalAdded,
                uint120 stakePoints,
                bool isActive,
                uint80 payoutPreCapitalAddIcsa,
                uint80 payoutPreCapitalAddHdrn,
                uint80 stakeAmount,
                uint16 minStakeLength
            );

        function increaseAllowance(address spender, uint256 addedValue)
            external
            returns (bool);

        function injectSeedLiquidity(uint256 amount, uint256 seedDays) external;

        function launchDay() external view returns (uint256);

        function name() external view returns (string memory);

        function nftPoolIcsaCollected() external view returns (uint256);

        function nftPoolPayout(uint256) external view returns (uint256);

        function nftPoolPoints(uint256) external view returns (uint256);

        function nftPoolPointsRemoved() external view returns (uint256);

        function nftStakeEnd(uint256 nftId) external returns (uint256);

        function nftStakeStart(uint256 amount, address tokenAddress)
            external
            payable
            returns (uint256);

        function nftStakes(uint256)
            external
            view
            returns (
                uint64 stakeStart,
                uint64 capitalAdded,
                uint120 stakePoints,
                bool isActive,
                uint80 payoutPreCapitalAddIcsa,
                uint80 payoutPreCapitalAddHdrn,
                uint80 stakeAmount,
                uint16 minStakeLength
            );

        function symbol() external view returns (string memory);

        function totalSupply() external view returns (uint256);

        function transfer(address to, uint256 amount) external returns (bool);

        function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);

        function waatsa() external view returns (address);
    }
    // used in ThankYouTeam escrow contract
    contract TEAMContract {
        function getCurrentPeriod() public view returns (uint256) {}
    }
    
    // https://etherscan.io/token/0x2b591e99afe9f32eaa6214f7b7629768c40eeb39#code
    contract HEXContract {
        function currentDay() external view returns (uint256){}
        function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external {}
        function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external {}
    }
    // unused, replaced with above hedron interface
    contract HedronContracts {
        struct HEXStakeMinimal {
        uint40 stakeId;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        }

        struct ShareStore {
            HEXStakeMinimal stake;
            uint16          mintedDays;
            uint8           launchBonus;
            uint16          loanStart;
            uint16          loanedDays;
            uint32          interestRate;
            uint8           paymentsMade;
            bool            isLoaned;
        }
        struct LiquidationStore{
            uint256 liquidationStart;
            address hsiAddress;
            uint96  bidAmount;
            address liquidator;
            uint88  endOffset;
            bool    isActive;
        }

    function currentDay() external view returns (uint256) {}
    function liquidationList(uint256 index) public view returns (LiquidationStore memory) {}
    function shareList(uint256 hshi_id) public view returns (ShareStore memory) {}
    function mintInstanced(uint256 hsiIndex,address hsiAddress) external returns (uint256){}
    function mintNative(uint256 stakeIndex, uint40 stakeId) external returns (uint256){}
    function loanLiquidate(address owner,uint256 hsiIndex,address hsiAddress) external returns (uint256) {}
    function loanLiquidateBid (uint256 liquidationId,uint256 liquidationBid) external returns (uint256) {}
    function loanLiquidateExit(uint256 hsiIndex, uint256 liquidationId) external returns (address) {}
    }
    // Contract that holds each individual HSI stake
    // This contract is deployed by the Hedron contract when each HSI is generated
    // example: https://etherscan.io/address/0x440C2f83B03e1AbCE3B5ab4dB02b2Da055Db5d29#code
    contract HSIContract{
        struct HEXStakeMinimal {
        uint40 stakeId;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        }

        struct ShareStore {
            HEXStakeMinimal stake;
            uint16          mintedDays;
            uint8           launchBonus;
            uint16          loanStart;
            uint16          loanedDays;
            uint32          interestRate;
            uint8           paymentsMade;
            bool            isLoaned;
        }
        struct HEXStake {
        uint40 stakeId;
        uint72 stakedHearts;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool   isAutoStake;
        }
    
        function share() public view returns (ShareStore memory) {}
        function goodAccounting() external {}
        function stakeDataFetch(
        ) 
            external
            view
            returns(HEXStake memory)
        {}
    }
    // Used for managing the HSIs
    // https://etherscan.io/address/0x8BD3d1472A656e312E94fB1BbdD599B8C51D18e3#code
    contract HSIManagerContract {
        mapping(address => address[]) public  hsiLists;
        function hexStakeDetokenize (uint256 tokenId) external returns (address) {}
        function hexStakeStart ( uint256 amount, uint256 length) external returns (address) {}
        function hexStakeEnd (uint256 hsiIndex,address hsiAddress) external returns (uint256) {}
        function ownerOf(uint256 tokenId) public view virtual returns (address) {}
        function hsiToken(uint256 hsiIndex) public view returns (address) {}
        function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual  returns (uint256) {}
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId
        ) public virtual  {}
        function transferFrom(
            address from,
            address to,
            uint256 tokenId
        ) external {}
    }





contract PolyMaximus is ERC20, ERC20Burnable, ReentrancyGuard {

    /*
    Poly Maximus is a HDRN pool for bidding in the HSIs available in the Hedron Liquidation Auctions.

    * Minting and Redemption Rules:
        - Mint 1 POLY per 1 HDRN deposited to the contract before MINTING_PHASE_END
        - after MINTING_PHASE_END, someone needs to run finalizeMinting() which activates bidding phase, stakes HDRN, and allocates the bidding budget.
        - The redemption phase begins once all stakes are ended. Users run redeemPoly() which burns POLY and transfers them the corresponding HEX, HDRN, and ICSA per the REDEMPTION_RATE values.
    
    * HSI Auction Executor
        - The Executor is an address, or set of addresses which are able to run the bid() function completely at their discretion.
        - Poly Maximus Participants agree to not have any expectations of the performance of The Executor. 
        - If the executor does not make any bids over any 30 day period, the bidding is considered done and the remaining HDRN gets staked via Icosa.
    
    * HSI Management:
        - As HSIs enter the contract after succesful auctions, someone needs to run processHSI() which records information about the stake and schedules the ending of the stakes.
        - After each HSI ends, someone needs to run endHSIStake() to mint the HDRN and end the HEX stake. If it is the last scheduled HSI, it activates the redemption period.
        - if one of the HSIs ends with at least a year left until the LAST_ACTIVE_HSI ends, the HEX is restaked until right before the LAST_ACTIVE_HSI ends and the HDRN is added to the Icosa Hedron stake.

    * Thank You Maximus Team:
        - As an expression of gratitude for the outsized benefits of participating in Poly Maximus, 1% of the incoming HDRN and 1% of the outgoing HEX is gifted to TEAM
            - of the 1% of the incoming HDRN:
                - 33% is distributed to TEAM stakers during year 1
                - 33% is distributed to TEAM stakers during year 2
                - 34% is sent to the Mystery Box Hot Address
            - The 1% of the outgoing HEX after all the stakes end is distributed to TEAM stakers during whichever year the last HSI ends.
    */




    
    /// Data Structures

        struct HEXStakeMinimal {
        uint40 stakeId;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        }

        struct ShareStore {
            HEXStakeMinimal stake;
            uint16          mintedDays;
            uint8           launchBonus;
            uint16          loanStart;
            uint16          loanedDays;
            uint32          interestRate;
            uint8           paymentsMade;
            bool            isLoaned;
        }
        struct LiquidationStore{
            uint256 liquidationStart;
            address hsiAddress;
            uint96  bidAmount;
            address liquidator;
            uint88  endOffset;
            bool    isActive;
        }

        struct LiquidationData {
            uint16          mintedDays;
            uint8           launchBonus;
            uint16          loanStart;
            uint16          loanedDays;
            uint32          interestRate;
            uint8           paymentsMade;
            bool            isLoaned;
            uint256 liquidationStart;
            address hsiAddress;
            uint96  bidAmount;
            address liquidator;
            uint88  endOffset;
            bool    isActive;
        }
        struct HEXStake {
                uint40 stakeId;
                uint72 stakedHearts;
                uint72 stakeShares;
                uint16 lockedDay;
                uint16 stakedDays;
                uint16 unlockedDay;
                bool   isAutoStake;
            }
    
    /// Events
        event Mint (address indexed user,uint256 amount);
        event Redeem (address indexed user, uint256 amount, uint256 hex_redeemed, uint256 hedron_redeemed, uint256 icosa_redeemed);
        event Bid(uint256 liquidationId, uint256 liquidationBid);
        event ProcessHSI(address indexed hsi_address, uint256 hsi_id);
   

    /// Contract interfaces
        address constant HEX_ADDRESS = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
        HEXContract hex_contract = HEXContract(HEX_ADDRESS);
        address constant HEDRON_ADDRESS=0x3819f64f282bf135d62168C1e513280dAF905e06; // 0xE183d9599fd1E0bae2f25529e3c5467C744153DD;//
        HedronContract hedron_contract = HedronContract(HEDRON_ADDRESS); 
        address constant HSI_MANAGER_ADDRESS =0x8BD3d1472A656e312E94fB1BbdD599B8C51D18e3;
        HSIManagerContract HSI_manager_contract = HSIManagerContract(HSI_MANAGER_ADDRESS); 
        address public ICOSA_CONTRACT_ADDRESS = 0x7A28cf37763279F774916b85b5ef8b64AB421f79; // mainnet: 0xfc4913214444aF5c715cc9F7b52655e788A569ed;
        IcosaInterface icosa_contract = IcosaInterface(ICOSA_CONTRACT_ADDRESS);
        address constant TEAM_ADDRESS = 0xB7c9E99Da8A857cE576A830A9c19312114d9dE02;
    /// Minting Variables

        uint256 public MINTING_PHASE_START;
        uint256 public MINTING_PHASE_END;
    /// Redemption Variables
        bool public IS_REDEMPTION_ACTIVE;
        uint256 public HEX_REDEMPTION_RATE; // Number of HEX units redeemable per POLY
        uint256 public HEDRON_REDEMPTION_RATE; // Number of HEDRON units redeemable per POLY
        uint256 public ICOSA_REDEMPTION_RATE; // Number of ICSA units redeemable per POLY
    
        uint256 div_scalar = 10**8;
    
    /// HSI Variables
        mapping (address => bool) END_STAKERS; // Addresses of the users who end HSI stakes on Poly Community's behalf, may be used in future gas pooling contracts
        uint256 public LAST_STAKE_START_DAY;
        uint256 public LATEST_STAKE_END_DAY;
        mapping (address => HEXStake) public HEXStakes;
        address public LAST_ACTIVE_HSI;
        
    
    /// Bid Execution Variables
        mapping (address => bool) IS_EXECUTOR; // mapping of addresses authorized to run executor functions
        bool IS_BIDDING_ACTIVE;
        // BIDDING_BUDGET_TRACKER and STAKING_BUDGET_TRACKER are used to calculate the bidding_budget_percent, updated as each user mints and votes.
        uint256 public BIDDING_BUDGET_TRACKER; 
        uint256 public STAKING_BUDGET_TRACKER;
        uint256 public TOTAL_BIDDING_BUDGET; // amount of HDRN able to be bid
        uint256 public HDRN_STAKING_BUDGET; // amount of HDRN allocated for staking
        uint256 public bidding_budget_percent; // percent of total HDRN able to be bid
        address public THANK_YOU_TEAM; // contract address for the ThankYouTeam Escrow contract
        bool public DID_STAKE_LEFTOVER;
        uint256 LAST_BID_PLACED_DAY; // Updated as each bid is placed, used to declare deadline

    constructor(uint256 mint_duration) ERC20("Poly Maximus TEST", "POLYTEST") ReentrancyGuard() {
        uint256 start_day=hex_contract.currentDay();
        TEST_CURRENT_DAY = start_day;
        MINTING_PHASE_START = start_day;
        MINTING_PHASE_END = start_day+mint_duration;
        LAST_BID_PLACED_DAY=MINTING_PHASE_END; // set to first eligible day to prevent stake_leftover_hdrn() from being run before first bid is placed
        LAST_STAKE_START_DAY= MINTING_PHASE_END+10; // HSIs must have started before this deadline in order to be processed.
        IS_EXECUTOR[0x093cCBBF9CBE45307dA150C7052eD442f58B8a58]=true;
        IS_EXECUTOR[0x4Ef500741280448Cb46A8eaDf68B86629294c95d]=true;   
        
    }
    /**
     * @dev Sets decimals to 9 - to be equal to that of HDRN.
     */
    function decimals() public view virtual override returns (uint8) {return 9;}

    /// Testnet only remove for mainnet
        /**
        * @dev Gets the current HEX Day.
        * @return hex_day current day per the HEX Contract.
        */
        function getCurrentDay() public view returns (uint256 hex_day) {
            return TEST_CURRENT_DAY;
            //return hex_contract.currentDay();
            } 
        uint256 public TEST_CURRENT_DAY;
        function incrementTestDay() public {
            require(IS_EXECUTOR[msg.sender]);
            TEST_CURRENT_DAY = TEST_CURRENT_DAY + 1;
        }

    /// Minting Phase Functions

        function mint(uint256 amount) private {_mint(msg.sender, amount);}

        /**
        * @dev Checks that mint phase is ongoing and that the user inputted bid budget percent is within the allowed range. Then it updates the global bidding_budget_percent value, transfers the amount of HDRN to the Poly contract, then mints the user the same number of POLY.
        * @param amount amount of HDRN minted into POLY.
        * @param bid_budget_percent percent of total HDRN the user thinks should be bid on HSIs.
        */
        function mintPoly(uint256 amount, uint256 bid_budget_percent) nonReentrant external {
            require(getCurrentDay()<=MINTING_PHASE_END, "Minting Phase must still be ongoing to mint POLY.");
            require(bid_budget_percent <= 100, "Bid Budget must not be greater than 100 percent.");
            require(bid_budget_percent >= 0, "Bid Budget Percent must not be less than 0 percent.");
            BIDDING_BUDGET_TRACKER = BIDDING_BUDGET_TRACKER + ((bid_budget_percent * amount)/100); // increments weighted running total bidding budget tracker
            STAKING_BUDGET_TRACKER = STAKING_BUDGET_TRACKER + (((100-bid_budget_percent) * amount)/100); // increments weighted running total staking budget tracker
            bidding_budget_percent = 100 * BIDDING_BUDGET_TRACKER / (BIDDING_BUDGET_TRACKER + STAKING_BUDGET_TRACKER); // calculates percent of total to be bid
            IERC20(HEDRON_ADDRESS).transferFrom(msg.sender, address(this), amount); // sends HDRN to the Poly Contract
            mint(amount); // Mints 1 POLY per 1 HDRN
            emit Mint(msg.sender, amount);
        }

        /*
        * @dev This function is run at the end of the minting phase to kick off the bidding phase. It checks if the minting phase is still ongoing, deploys the ThankYouTeam escrow contract, allocates the amount used to Thank TEAM, calculates the Bidding and Staking budgets, and stakes the HDRN staking budget.
        */
        function finalizeMinting() external nonReentrant {
            require(getCurrentDay()> MINTING_PHASE_END);
            require(IS_BIDDING_ACTIVE ==false);
            ThankYouTeam tyt = new ThankYouTeam();
            THANK_YOU_TEAM = address(tyt);
            uint256 total_hdrn = IERC20(HEDRON_ADDRESS).balanceOf(address(this));
            uint256 thank_you_team = 100 * total_hdrn / 10000; // Poly thanks TEAM for saving them 99% on gas fees and letting them have HDRN staking bonuses with 1% of the total HDRN pledged.
            IERC20(HEDRON_ADDRESS).transfer(THANK_YOU_TEAM, thank_you_team);
            TOTAL_BIDDING_BUDGET = (total_hdrn - thank_you_team) * bidding_budget_percent/100;
            HDRN_STAKING_BUDGET = (total_hdrn - thank_you_team) - TOTAL_BIDDING_BUDGET;
            IERC20(HEDRON_ADDRESS).approve(ICOSA_CONTRACT_ADDRESS, HDRN_STAKING_BUDGET);
            icosa_contract.hdrnStakeStart(HDRN_STAKING_BUDGET);
            IS_BIDDING_ACTIVE = true;
        }

    /// Redemption Functions
        /**
        * @dev Checks that redemption phase is ongoing and that the amount requested is less than the user's POLY balance. Then it calculates the amount of HEX, HDRN, and ICOSA that is redeemable for the amount input by the user, burns that amount and transfers them their alloted HEX, HDRN, and ICOSA.
        * @param amount amount of POLY being redeemed.
        */
        function redeemPoly(uint256 amount) nonReentrant external {
            require(IS_REDEMPTION_ACTIVE==true, "Redemption can only happen at end.");
            uint256 current_balance = balanceOf(msg.sender);
            require(amount<=current_balance, "insufficient balance");
            uint256 redeemable_hex = amount * HEX_REDEMPTION_RATE / div_scalar;
            uint256 redeemable_hedron = amount * HEDRON_REDEMPTION_RATE / div_scalar;
            uint256 redeemable_icosa = amount * ICOSA_REDEMPTION_RATE / div_scalar;
            burn(amount);
            if (redeemable_hex > 0 ) {
                IERC20(HEX_ADDRESS).transfer(msg.sender, redeemable_hex);
            }
            if (redeemable_hedron > 0 ) {
                IERC20(HEDRON_ADDRESS).transfer(msg.sender, redeemable_hedron);
            }
            if (redeemable_icosa > 0 ) {
                IERC20(ICOSA_CONTRACT_ADDRESS).transfer(msg.sender, redeemable_icosa);
            }
            emit Redeem(msg.sender, amount, redeemable_hex, redeemable_hedron, redeemable_icosa);
        }
        

        function calculate_redemption_rate(uint256 balance, uint256 supply) public view returns (uint256 redemption_rate) {
            uint256 scaled_redemption_rate = balance * div_scalar / supply;
            return scaled_redemption_rate;
        }
 
        function set_redemption_rate() private {
            HEX_REDEMPTION_RATE = calculate_redemption_rate(IERC20(HEX_ADDRESS).balanceOf(address(this)), totalSupply());
            HEDRON_REDEMPTION_RATE = calculate_redemption_rate(IERC20(HEDRON_ADDRESS).balanceOf(address(this)), totalSupply());
            ICOSA_REDEMPTION_RATE =  calculate_redemption_rate(IERC20(ICOSA_CONTRACT_ADDRESS).balanceOf(address(this)), totalSupply());
        }
    /// Liquidation Auction Management
        /*
        * @dev Bids on liquidations. It checks to make sure the bid is within the maximum bid allowance, ensures that bidding is still active, and that the caller of this function is in the whitelisted executor list. Then it places the bid via the Hedron contract.
        * @param liquidationId - unique identifier for the liquidation
        * @param liquidationBid - bid amount determined by executor.
        */
        function bid(uint256 liquidationId, uint256 liquidationBid) external nonReentrant {
            LiquidationData memory liquidation = getLiquidation(liquidationId);
            uint256 max_bid = liquidation.bidAmount + 10000*10**9;
            require(liquidationBid < max_bid);
            require(IS_BIDDING_ACTIVE);
            require(IS_EXECUTOR[msg.sender]);
            hedron_contract.loanLiquidateBid(liquidationId, liquidationBid);
            LAST_BID_PLACED_DAY = getCurrentDay();
            emit Bid(liquidationId, liquidationBid);
        }
    
        /*
        * @dev Gets the information about the liquidation, and the HSI.
        * @param liquidation_index Hedron liquidation auction identifier
        * return liquidation_data Liquidation information including: mintedDays, launchBonus, loanStart , loanedDays, interestRate, paymentsMade, isLoaned, liquidationStart, hsiAddress, bidAmount, liquidator, endOffset, isActive
        */
        function getLiquidation(uint256 liquidation_index) public view returns (LiquidationData memory liquidation_data) {
            
            uint256 liquidationStart=hedron_contract.liquidationList(liquidation_index).liquidationStart; 
            address hsiAddress=hedron_contract.liquidationList(liquidation_index).hsiAddress;
            uint96  bidAmount=hedron_contract.liquidationList(liquidation_index).bidAmount;
            address liquidator=hedron_contract.liquidationList(liquidation_index).liquidator;
            uint88  endOffset=hedron_contract.liquidationList(liquidation_index).endOffset;
            bool    isActive=hedron_contract.liquidationList(liquidation_index).isActive;
            uint16         mintedDays=  HSIContract(hsiAddress).share().mintedDays;
            uint8          launchBonus = HSIContract(hsiAddress).share().launchBonus;
            uint16         loanStart =  HSIContract(hsiAddress).share().loanStart;
            uint16         loanedDays =HSIContract(hsiAddress).share().loanedDays;
            uint32         interestRate= HSIContract(hsiAddress).share().interestRate;
            uint8          paymentsMade = HSIContract(hsiAddress).share().paymentsMade;
            bool           isLoaned = HSIContract(hsiAddress).share().isLoaned;
            LiquidationData memory liquidation = LiquidationData(
            mintedDays, launchBonus, loanStart , loanedDays, interestRate, paymentsMade, isLoaned,
            liquidationStart, hsiAddress, bidAmount, liquidator, endOffset, isActive
            );
            return liquidation;
        }
        
        /*
        * @dev Stakes the leftover hedron. First it checks to make sure the bidding phase is over and stakes the leftover HDRN via hdrnStakeAddCapital
        */
        function stake_leftover_hdrn() external nonReentrant {
            require(getCurrentDay() - LAST_BID_PLACED_DAY >30); // 30 days must have passed from the last bid to stake leftover HDRN
            require(DID_STAKE_LEFTOVER==false);
            uint256 days_til_redemption = LATEST_STAKE_END_DAY - getCurrentDay();
            require(days_til_redemption > 366, "This must not extend the stake past the redemption phase.");
            icosa_contract.hdrnStakeAddCapital(IERC20(HEDRON_ADDRESS).balanceOf(address(this)));
            DID_STAKE_LEFTOVER = true; 
        }

        
    /// HSI Management
        /*
        * @dev Run this function when a new HSI is won by the contract. It saves a new entry in the HEXStake mapping and determines if the HSI is the one that ends on the latest day.
        * @param hsi_id Unique ID for the HSI.
        */
        function processHSI(uint256 hsi_id) external nonReentrant {
            address hsi_address = HSI_manager_contract.hsiToken(hsi_id);
            address hsi_owner = HSI_manager_contract.ownerOf(hsi_id);
            require(hsi_owner==address(this), "Can only process HSIs owned by Poly Contract.");
            HSIContract hsi = HSIContract(hsi_address);
            require(hsi.stakeDataFetch().lockedDay<LAST_STAKE_START_DAY);
            HEXStake storage stake = HEXStakes[hsi_address];
            stake.stakeId = hsi.stakeDataFetch().stakeId;
            stake.stakedHearts =hsi.stakeDataFetch().stakedHearts;
            stake.stakeShares = hsi.stakeDataFetch().stakeShares;
            stake.lockedDay = hsi.stakeDataFetch().lockedDay;
            stake.stakedDays = hsi.stakeDataFetch().stakedDays;
            stake.unlockedDay = hsi.stakeDataFetch().stakedDays;
            stake.isAutoStake = hsi.stakeDataFetch().isAutoStake;
            uint256 end_day= stake.lockedDay + stake.stakedDays;
            if (end_day>LATEST_STAKE_END_DAY) {
                LATEST_STAKE_END_DAY = end_day;
                LAST_ACTIVE_HSI = hsi_address;
            }
            HSI_manager_contract.hexStakeDetokenize(hsi_id);
            emit ProcessHSI(hsi_address, hsi_id);
        }
        /*
        * @dev Ends the HSI stake, if it is eligible to end. If it is the last active HSI in the list, it activates the redemption period and sends a HEX tip to TEAM. if it is not the last one and there is more than a year until the last active HSI, it restakes the HEX and HDRN. Then it calculates the redemption rates.
        * @param hsiIndex HSI identifier
        * @param hsiAddress HSI unique contract address
        */
        function endHSIStake(uint256 hsiIndex, address hsiAddress) external nonReentrant {
            HEXStake storage stake = HEXStakes[hsiAddress];
            require(stake.lockedDay + stake.stakedDays < getCurrentDay(), "This stake has not ended yet");
            hedron_contract.mintInstanced(hsiIndex, hsiAddress);
            HSI_manager_contract.hexStakeEnd(hsiIndex, hsiAddress);
            if (hsiAddress == LAST_ACTIVE_HSI) {
                icosa_contract.hdrnStakeEnd();
                IS_REDEMPTION_ACTIVE = true;
                uint256 thank_you_team = 100 * IERC20(HEX_ADDRESS).balanceOf(address(this)) / 10000;
                IERC20(HEX_ADDRESS).transfer(TEAM_ADDRESS, thank_you_team);
            } 
            set_redemption_rate();
            END_STAKERS[msg.sender]=true;
        }
        /*
        @dev Checks if there is adequate time left and restakes leftover HEX and HDRN.
        */
        function restake_leftover() external nonReentrant {
            require(IS_REDEMPTION_ACTIVE == false);
            uint256 days_til_redemption = LATEST_STAKE_END_DAY - getCurrentDay();
            if (days_til_redemption > 366) {
                hex_contract.stakeStart(IERC20(HEX_ADDRESS).balanceOf(address(this)), days_til_redemption - 3);
                icosa_contract.hdrnStakeAddCapital(IERC20(HEDRON_ADDRESS).balanceOf(address(this)));
                set_redemption_rate();
            }
        }

        /*
        * @dev Mints the HDRN from the stake, ends the stake, and calculates the redemption rate.
        * @param stakeIndex - index among list of users stakes
        * @param stakeIdParam - unique ID for hex stake
        */ 
        function endNativeStake(uint256 stakeIndex, uint40 stakeIdParam) external nonReentrant {
            require(getCurrentDay() >= LATEST_STAKE_END_DAY - 2);
            hedron_contract.mintNative(stakeIndex, stakeIdParam);
            hex_contract.stakeEnd(stakeIndex, stakeIdParam);
            set_redemption_rate();
        }

        
    
        
        

}

contract ThankYouTeam {
    // THIS CONTRACT IS AN EXPRESSION OF GRATITUDE TO MAXIMUS TEAM FOR SAVING THE HSI BIDDERS FROM HOLDING THE BAG ON HSIs IMPACTED BY GAS FEES
    address TEAM_ADDRESS =0xB7c9E99Da8A857cE576A830A9c19312114d9dE02;
    address constant HEDRON_ADDRESS=0x3819f64f282bf135d62168C1e513280dAF905e06;//0xE183d9599fd1E0bae2f25529e3c5467C744153DD;//0x3819f64f282bf135d62168C1e513280dAF905e06;
    address mystery_box_hot =0x00C055Ee792B5bC9AeB06ced73bB71ce7E5773Ce;
    mapping (uint => uint256) public schedule;
    uint256 percent_year_one = 33;
    uint256 percent_year_two = 33;
    bool IS_SCHEDULED;
    constructor() {
    }
    /*
    * @dev This schedules the distributions allocated to TEAM stakers during years one and two, and sends the Mystery Box hot address a reward.
    */
    function schedule_distribution() public {
        require(IS_SCHEDULED==false);
        schedule[1]=IERC20(HEDRON_ADDRESS).balanceOf(address(this)) * percent_year_one / 100;
        schedule[3]=IERC20(HEDRON_ADDRESS).balanceOf(address(this)) * percent_year_two / 100;
        uint256 mb_amt = IERC20(HEDRON_ADDRESS).balanceOf(address(this)) - (schedule[1]+schedule[3]);
        IERC20(HEDRON_ADDRESS).transfer(mystery_box_hot, mb_amt);
        IS_SCHEDULED=true;
    }
    /*
    * @dev This sends the funds to the TEAM contract during the qualified years, then prevents it from being sent again that year.
    */
    function distribute() public {
        require(IS_SCHEDULED, "The distributions have not been scheduled yet, run schedule_distribution() first.");
        uint256 current_period = TEAMContract(TEAM_ADDRESS).getCurrentPeriod();
        uint256 amt = schedule[current_period];
        require(amt>0, "There are no available funds to be distributed this year. Either it is not a qualified year, or it has already been run this year.");
        IERC20(HEDRON_ADDRESS).transfer(TEAM_ADDRESS, amt);
        schedule[current_period]=0;
    }
     
}

