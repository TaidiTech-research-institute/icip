/// Module translated from [ICIP-1](https://github.com/sailfish-app/proposals/blob/master/icip-1.md) code.
/// Added some refined classes and functions.
///
/// The ICIP-1 token interface
/// Include this library in your code to impliment a token in a canister.
///
/// Pseudo code:
/// ```motoko
/// import ICIP1 "mo:icip/ICIP-1";
/// 
/// actor token {
///   public query func getBalance(requests: [ICIP1.BalanceRequest]): async ICIP1.BalanceResponse {
///     let balance: Nat = 0: Nat;
///     #ok([balance]);
///   };
///   public query func getMetadata(tokenIds: [ICIP1.TokenId]): async ICIP1.MetadataResponse {
///     let metadata: ICIP1.Metadata = "icip-token";
///     #ok([metadata]);
///   };
///   public shared func transfer(requests: [ICIP1.TransferRequest]): async ICIP1.TransferResponse {
///     #ok();
///   };
///   public shared func updateOperator(requests: [ICIP1.OperatorRequest]): async ICIP1.OperatorResponse {
///     #ok();
///   };
///   public query func isAuthorized(requests: [ICIP1.IsAuthorizedRequest]): async ICIP1.IsAuthorizedResponse {
///     [true]
///   };
/// };
/// ```
/// Go to ICIPTest.mo to find how to implement this package to your code.

import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {
  // A user can be any principal or canister
  public type User = Principal;

  // A Nat32 implies each canister can store 2**32 individual tokens
  public type TokenId = Nat32;

  // Token amounts are unbounded
  public type Balance = Nat;

  // Details for a token, eg. name, symbol, description, decimals.
  // Metadata format TBD, possible option is JSON blob
  public type Metadata = Text;
  public type MetadataResponse = Result.Result<[Metadata], {
    #InvalidToken: TokenId;
  }>;

  // Request and responses for getBalance
  public type BalanceRequest = {
    user: User;
    tokenId: TokenId;
  };
  public type BalanceResponse = Result.Result<[Balance], {
    #InvalidToken: TokenId;
  }>;

  // Request and responses for transfer
  public type TransferRequest = {
    from: User;
    to: User;
    tokenId: TokenId;
    amount: Balance;
  };
  public type TransferResponse = Result.Result<(), {
    #Unauthorized;
    #InvalidDestination: User;
    #InvalidToken: TokenId;
    #InsufficientBalance;
  }>;

  // Request and responses for updateOperator
  public type OperatorAction = {
    #AddOperator;
    #RemoveOperator;
  };
  public type OperatorRequest = {
    owner: User;
    operators: [(User, OperatorAction)];
  };
  public type OperatorResponse = Result.Result<(), {
    #Unauthorized;
    #InvalidOwner: User;
  }>;

  // Request and responses for isAuthorized
  public type IsAuthorizedRequest = {
    owner: User;
    operator: User;
  };
  public type IsAuthorizedResponse = [Bool];

  /// utilities

  // class of User  
  public class IUser () {
    public let equal = Principal.equal;
    public let hash = Principal.hash;
  };

  // class of TokenId
  public class ITokenId (id: TokenId, id2: TokenId) {
    public func equal() : Bool { id == id2 };
    public func hash() : Hash.Hash { id };
  };

  // Uniquely identifies a token
  public type TokenIdentifier = {
    canister: Token;
    tokenId: TokenId;
  };

  // class of TokenIdentifier
  public class ITokenIdentifier (ti: TokenIdentifier, ti2: TokenIdentifier) {
    // Tokens are equal if the canister and tokenId are equal
    public func equal() : Bool {
      Principal.fromActor(ti.canister) == Principal.fromActor(ti2.canister)
      and ti.tokenId == ti2.tokenId
    };
    // Hash the canister and xor with tokenId
    public func hash() : Hash.Hash {
      Principal.hash(Principal.fromActor(ti.canister)) ^ ti.tokenId
    };
    // Join the principal and id with a '_'
    public func toText() : Text {
      Principal.toText(Principal.fromActor(ti.canister)) # "_" # Nat32.toText(ti.tokenId)
    };
  };

  /**
    A token canister that can hold many tokens.
  */
  public type Token = actor {
    /**
      Batch get balances.
      Any request with an invalid tokenId should cause the entire batch to fail.
      A user that has no token should default to 0.
    */
    getBalance: query (requests: [BalanceRequest]) -> async BalanceResponse;

    /**
      Batch get metadata.
      Any request with an invalid tokenId should cause the entire batch to fail.
    */
    getMetadata: query (tokenIds: [TokenId]) -> async MetadataResponse;

    /**
      Batch transfer.
      A request should fail if:
        - the caller is not authorized to transfer for the sender
        - the sender has insufficient balance
      Any request that fails should cause the entire batch to fail, and to
      rollback to the initial state.
    */
    transfer: shared (requests: [TransferRequest]) -> async TransferResponse;

    /**
      Batch update operator.
      A request should fail if the caller is not authorized to update operators
      for the owner.
      Any request that fails should cause the entire batch to fail, and to
      rollback to the initial state.
    */
    updateOperator: shared (requests: [OperatorRequest]) -> async OperatorResponse;

    /**
      Batch function to check if a user is authorized to transfer for an owner.
    */
    isAuthorized: query (requests: [IsAuthorizedRequest]) -> async IsAuthorizedResponse;
  };
}
