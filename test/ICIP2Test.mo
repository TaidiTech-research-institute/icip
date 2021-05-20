import M "mo:matchers/Matchers";
import ICIP2 "../src/ICIP2";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";

let ParamsInit = S.suite("ParamsInit", do {
    Debug.print("ParamsInit");
    var tests : [S.Suite] = [];
    
    // token attributes
    let owner: ICIP2.Owner = Principal.fromActor(actor "ryjl3-tyaaa-aaaaa-aaaba-cai");
    let name: ICIP2.Name = "ICP20 Token Canister";
    let decimals: ICIP2.Decimals = 18;
    let symbol: ICIP2.Symbol = "ICP20";
    let totalSupply: ICIP2.TotalSupply = 123456789;
    
    // assign params
    let alice = Principal.fromText("bx3v7-ogsy2-p64w7-ra77s-il633-ixu5y-ons34-vhghi-kruft-b6o6t-dqe");
    let bob = Principal.fromText("pc5d2-fhhon-5geo3-euvhw-hokpr-v2ng5-axewa-wox77-fxpqq-n6ffy-5qe");
    let delegate = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    // basic functions
    let equal = ICIP2.equal(alice, alice);
    let hash = ICIP2.hash(bob);
    // test basic functions
    tests := Array.append(tests, [S.test("ok", equal, M.equals(T.bool(true)))]);
    tests := Array.append(tests, [S.test("ok", Hash.equal(hash, Principal.hash(bob)), M.equals(T.bool(true)))]);

    // function hash map
    let balance = ICIP2.Balance<Principal, Nat>(1, Principal.equal, Principal.hash);
    let allowance = ICIP2.Allowance<Principal, HashMap.HashMap<Principal, Nat>>(1, Principal.equal, Principal.hash);
    balance.put(owner, totalSupply);
    delegate.put(bob, 1);
    allowance.put(alice, delegate);
    // test function hash map
    switch (balance.get(owner)) {
      case (?balance) {
        tests := Array.append(tests, [S.test("ok", balance, M.equals(T.nat(123456789)))]);
      };
      case null {};
    };

    switch (delegate.get(bob)) {
      case (?value) {
        tests := Array.append(tests, [S.test("ok", value, M.equals(T.nat(1)))]);
      };
      case null {};
    };

    switch (allowance.get(alice)) {
      case (?delegate) {
        switch (delegate.get(bob)) {
          case (?value) { 
            tests := Array.append(tests, [S.test("ok", value, M.equals(T.nat(1)))]);
          };
          case null {};
        };
      };
      case null {};
    };

    tests
});

let suite = S.suite("ICIP2", [
  ParamsInit
]);

S.run(suite);
