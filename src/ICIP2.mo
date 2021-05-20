/// Module interface refered and rewritten from [motoko-token](https://github.com/dfinance-tech/motoko-token) code.
///
/// ERC20 style token template for Dfinity
/// Include this module in your code to implement an ERC20 style token in a canister.
///
/// Import this module:
/// ```motoko
/// import ICIP2 "mo:icip/ICIP2";
/// ```
///
/// For usage of this module: go to ICIP2Test.mo to find how to implement this module in your code, or refer to [demo.sh](https://github.com/dfinance-tech/motoko-token/blob/master/demo.sh).

import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";

module {
    // token owner
    public type Owner = Principal;
    // token name
    public type Name = Text;
    // token decimals
    public type Decimals = Nat;
    // token symbol
    public type Symbol = Text;
    // token total supply
    public type TotalSupply = Nat;

    // equal and hash function
    public let equal = Principal.equal;
    public let hash = Principal.hash;

    // balance hash map
    public let Balance = HashMap.HashMap;
    // allowance hash map
    public let Allowance = HashMap.HashMap;
    
    // Transfer request
    public type TransferRequest = {
        to: Principal;
        value: Nat;
    };

    // Mint request 
    public type MintRequest = {
        to: Principal;
        value: Nat;
    };

    // Transfer from
    public type TransferFromRequest = {
        from: Principal;
        transfer: TransferRequest;
    };

    // Approval request
    public type ApprovalRequest = {
        spender: Principal;
        value: Nat;
    };

    // Burn request
    public type BurnRequest = {
        from: Principal;
        value: Nat;
    };

    // Allowance request to allow to person to spent
    public type AllowanceRequest = {
        owner: Owner;
        spender: Principal;
    };

    // Initial request let you init a token canister
    public type InitialRequest = {
        owner: Owner;
        totalSupply: TotalSupply;
    };
    
    // A singular token canister
    public type Token = actor {

        init: shared (request: InitialRequest) -> async Null;

        transfer: shared (request: TransferRequest) -> async Bool;

        transferFrom: shared (request: TransferFromRequest) -> async Bool;

        approve: shared (request: ApprovalRequest) -> async Bool;

        mint: shared (request: MintRequest) -> async Bool;

        burn: shared (request: BurnRequest) -> async Bool;

        balanceOf: query (who: Principal) -> async Nat;

        allowance: query (request: AllowanceRequest) -> async Nat;

        totalSupply: query () -> async TotalSupply;

        name: query() -> async Name;

        decimals: query() -> async Decimals;

        symbol: query() -> async Symbol;

        owner: query() -> async Owner;

    };
}