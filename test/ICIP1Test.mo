import M "mo:matchers/Matchers";
import ICIP1 "../src/ICIP1";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Word32 "mo:base/Word32";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Prim "mo:prim";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";

// Can't test actor w/o main class: type error [M0141], an actor or actor class must be the only non-imported declaration in a program
// (This is a limitation of the current version.)
// actor token {
//    public query func getBalance(requests: [ICIP1.BalanceRequest]): async ICIP1.BalanceResponse {
//      let balance: Nat = 0: Nat;
//      #ok([balance]);
//    };
//    public query func getMetadata(tokenIds: [ICIP1.TokenId]): async ICIP1.MetadataResponse {
//      let metadata: ICIP1.Metadata = "icip-token";
//      #ok([metadata]);
//    };
//    public shared func transfer(requests: [ICIP1.TransferRequest]): async ICIP1.TransferResponse {
//      #ok();
//    };
//    public shared func updateOperator(requests: [ICIP1.OperatorRequest]): async ICIP1.OperatorResponse {
//      #ok();
//    };
//    public query func isAuthorized(requests: [ICIP1.IsAuthorizedRequest]): async ICIP1.IsAuthorizedResponse {
//      [true]
//    };
// };

let IUser = S.suite("IUser", do {
  Debug.print("IUser");
  var tests : [S.Suite] = [];
  let user = ICIP1.IUser();
  let user1: ICIP1.User = Principal.fromActor(actor "ryjl3-tyaaa-aaaaa-aaaba-cai");
  let user2: ICIP1.User = Principal.fromActor(actor "r7inp-6aaaa-aaaaa-aaabq-cai");
  // test equal function
  tests := Array.append(tests, [S.test("ok", user.equal(user1, user1), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", user.equal(user1, user2), M.equals(T.bool(false)))]);
  // test hash function
  let user1Hash = Blob.hash (Prim.blobOfPrincipal(user1));
  let user2Hash = Blob.hash (Prim.blobOfPrincipal(user2));
  // ok
  tests := Array.append(tests, [S.test("ok", Word32.equal(user.hash(user1), user1Hash), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("ok", Word32.equal(user.hash(user2), user2Hash), M.equals(T.bool(true)))]);
  // err
  tests := Array.append(tests, [S.test("err", Word32.equal(user.hash(user1), user2Hash), M.equals(T.bool(false)))]);
  tests := Array.append(tests, [S.test("err", Word32.equal(user.hash(user2), user1Hash), M.equals(T.bool(false)))]);
  tests
});

let ITokenId = S.suite("ITokenId", do {
  Debug.print("ITokenId");
  var tests : [S.Suite] = [];
  let tokenId1 = ICIP1.ITokenId(1, 1);
  tests := Array.append(tests, [S.test("ok", tokenId1.equal(), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("ok", Word32.equal(tokenId1.hash(), Word32.fromNat(1: Nat)), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Word32.equal(tokenId1.hash(), Word32.fromNat(2: Nat)), M.equals(T.bool(false)))]);
  let tokenId2 = ICIP1.ITokenId(2, 1);
  tests := Array.append(tests, [S.test("err", tokenId2.equal(), M.equals(T.bool(false)))]);
  tests := Array.append(tests, [S.test("ok", Word32.equal(tokenId2.hash(), Word32.fromNat(2: Nat)), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Word32.equal(tokenId2.hash(), Word32.fromNat(1: Nat)), M.equals(T.bool(false)))]);
  tests
});

// TODO actor inside this
let ITokenIdentifier = S.suite("ITokenIdentifier", do {
  Debug.print("ITokenIdentifier");
  var tests : [S.Suite] = [];
  // user 
  let alice: ICIP1.User = Principal.fromText("bx3v7-ogsy2-p64w7-ra77s-il633-ixu5y-ons34-vhghi-kruft-b6o6t-dqe");
  let bob: ICIP1.User = Principal.fromText("pc5d2-fhhon-5geo3-euvhw-hokpr-v2ng5-axewa-wox77-fxpqq-n6ffy-5qe");
  // Balance
  let balance: ICIP1.Balance = 0;
  // Metadata
  let metadata: ICIP1.Metadata = "icip-token";
  // token id
  let tokenId1: ICIP1.TokenId = 1: Nat32;
  let tokenId2: ICIP1.TokenId = 2: Nat32;
  // BalanceRequest
  let balanceRequest1:  ICIP1.BalanceRequest = {
    user = alice;
    tokenId = tokenId1;
  };
  let balanceRequest2: ICIP1.BalanceRequest = {
    user = bob;
    tokenId = tokenId2;
  };
  // TransferRequest
  let transferRequest1: ICIP1.TransferRequest = { 
    from = alice;
    to = bob;
    tokenId = tokenId1;
    amount = balance;
  };
  // OperatorAction
  let operatorAction: ICIP1.OperatorAction = do {
    #AddOperator;
  };
  // OperatorRequest
  let operatorRequest: ICIP1.OperatorRequest = {
    owner = alice;
    operators = [(bob, operatorAction)];
  };
  // IsAuthorizedRequest
  let isAuthorizedRequest: ICIP1.IsAuthorizedRequest = {
    owner = alice;
    operator = bob;
  };

  // token identifier
  // Can't assign local dut to this: type error [M0069], non-toplevel actor; an actor can only be declared at the toplevel of a program
  // (This is a limitation of the current version.)
  let tokenIdentifier1: ICIP1.TokenIdentifier = {
    canister = actor "ryjl3-tyaaa-aaaaa-aaaba-cai";
    tokenId = tokenId1;
  };
  let tokenIdentifier2: ICIP1.TokenIdentifier = {
    canister = actor "r7inp-6aaaa-aaaaa-aaabq-cai";
    tokenId = tokenId2;
  };
  // ITokenIdentifier
  let tokenIdentifierTest1 = ICIP1.ITokenIdentifier(tokenIdentifier1, tokenIdentifier2);
  tests := Array.append(tests, [S.test("err", tokenIdentifierTest1.equal(), M.equals(T.bool(false)))]);
  let hash = Principal.hash(Principal.fromActor(tokenIdentifier1.canister)) ^ Word32.fromNat(Nat32.toNat(tokenIdentifier1.tokenId));
  tests := Array.append(tests, [S.test("ok", Word32.equal(tokenIdentifierTest1.hash(), hash), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Word32.equal(tokenIdentifierTest1.hash(), Word32.fromNat(2: Nat)), M.equals(T.bool(false)))]);
  let text = Principal.toText(Principal.fromActor(tokenIdentifier1.canister)) # "_" # Nat32.toText(tokenIdentifier1.tokenId);
  tests := Array.append(tests, [S.test("ok", Text.equal(tokenIdentifierTest1.toText(), text), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Text.equal(tokenIdentifierTest1.toText(), "text"), M.equals(T.bool(false)))]);

  let tokenIdentifierTest2 = ICIP1.ITokenIdentifier(tokenIdentifier2, tokenIdentifier2);
  tests := Array.append(tests, [S.test("ok", tokenIdentifierTest2.equal(), M.equals(T.bool(true)))]);
  let hash2 = Principal.hash(Principal.fromActor(tokenIdentifier2.canister)) ^ Word32.fromNat(Nat32.toNat(tokenIdentifier2.tokenId));
  tests := Array.append(tests, [S.test("ok", Word32.equal(tokenIdentifierTest2.hash(), hash2), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Word32.equal(tokenIdentifierTest2.hash(), Word32.fromNat(1: Nat)), M.equals(T.bool(false)))]);
  let text2 = Principal.toText(Principal.fromActor(tokenIdentifier2.canister)) # "_" # Nat32.toText(tokenIdentifier2.tokenId);
  tests := Array.append(tests, [S.test("ok", Text.equal(tokenIdentifierTest2.toText(), text2), M.equals(T.bool(true)))]);
  tests := Array.append(tests, [S.test("err", Text.equal(tokenIdentifierTest2.toText(), "text2"), M.equals(T.bool(false)))]);

  tests
});

let suite = S.suite("ICIP1", [
  IUser,
  ITokenId,
  ITokenIdentifier,
]);

S.run(suite);
