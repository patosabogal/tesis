type Ref;
type Transaction;
const unique zero: Ref;

// TypeEnum constants
// These are configured on the 'verify' procedure. TODO: Configure all
var Payment: Ref;
var KeyRegistration: Ref;
var AssetConfig: Ref;
var AssetTransfer: Ref;
var AssetFreeze: Ref;
var ApplicationCall: Ref;


// OnComplete constants
const Noop : int;
const OptIn: int;
const CloseOut: int;
const ClearState: int;
const UpdateApplication: int;
const DeleteApplication: int;

// tx state
var Alloc: [Ref] bool;
var GlobalsAlloc: [Ref] bool;
var Globals: [int] int;
var GlobalsExAlloc: [Ref][Ref] bool;
var GlobalsEx: [Ref][Ref] Ref;
var LocalsAlloc: [Ref][Ref] bool;
var Locals: [int][int] Ref;
var LocalsExAlloc: [Ref][Ref][Ref] bool;
var LocalsEx: [Ref][Ref][Ref] Ref;
var ScratchSpace: [int] int;
var ScratchSpaceAlloc: [int] bool;
var StackPointer: int;
var Stack: [int] Ref;
var IsInt: [Ref] bool;
var RefToInt: [Ref] int;
var AssetBalance: [Ref] [int] int; // account, assetId
var AssetFrozen: [Ref] [int] int; // account, assetId
var OptedInApp: [Ref] [int] int; // account, appId
var OptedInAsset: [Ref] [int] int; // account, assetId

var GroupSize: int;
var Round: int;

// Modeling txns
var GroupIndex: [Transaction] int;
var CurrentTxn: Transaction;
var GroupTransaction: [int] Transaction;
var Sender : [Transaction] int;
var NumAppArgs : [Transaction] int;
var ApplicationArgs : [Transaction] [int] int;
var OnCompletion : [Transaction] int;
var Accounts : [Transaction] [int] int;
var ApplicationID : [Transaction] int;
var TypeEnum: [Transaction] int;
var AssetReceiver: [Transaction] int;
var XferAsset: [Transaction] int;
var AssetAmount: [Transaction] int;

const Creator : int;
const NotCreator : int;

var _: Ref;

// declare srings
var creator: int;
var regBegin: int;
var regEnd: int;
var voteBegin: int;
var voteEnd: int;
var register: int;
var vote: int;
var voted: int;
var candidatea: int;
var candidateb: int;

//procedure FreshRefGenerator() returns (newRef: Ref);
//  modifies Alloc;
//  modifies IsInt;
//implementation FreshRefGenerator() returns (newRef: Ref) {
//    havoc newRef;
//    assume Alloc[newRef] == false;
//    Alloc[newRef] := true;
//    IsInt[newRef] := false;
//    assume newRef != zero;
//  }
//
//procedure Push(value: Ref);
//  modifies Stack;
//  modifies StackPointer;
//implementation Push(value: Ref) {
//  StackPointer := StackPointer + 1;
//  Stack[StackPointer] := value;
//  }
//
//procedure Pop() returns (top: Ref);
//  requires StackPointer >= 0;
//  modifies StackPointer;
//implementation Pop() returns (top: Ref){
//  top := Stack[StackPointer];
//  StackPointer := StackPointer - 1;
//  }
//
//procedure Store(i: int);
//  requires 0 <= i ;
//  requires i < 64;
//  requires StackPointer >= 0;
//  modifies ScratchSpace;
//  modifies ScratchSpaceAlloc;
//  modifies Stack;
//  modifies StackPointer;
//implementation Store(i: int) {
//  var value: Ref;
//  call value := Pop();
//  ScratchSpaceAlloc[i] := true;
//  ScratchSpace[i] := value;
//  }
//
//procedure Load(i: int);
//  requires 0 <= i ;
//  requires i < 64;
//  requires ScratchSpaceAlloc[i] == true;
//  modifies Stack;
//  modifies StackPointer;
//implementation Load(i: int) {
//  call Push(ScratchSpace[i]);
//  }
//
//// Returns any Ref
//// TODO: DOUBLE CHECK THIS
//// TODO: PROBABLY SHOULD POP STUFF
//procedure AppGlobalGetEx();
//  requires StackPointer > 0;
//implementation AppGlobalGetEx() {
//  //var value: Ref;
//  //var _: Ref;
//  //havoc value;
//  //call _ := Pop();
//  //call _ := Pop();
//  //call Push(value);
//  call Int(1);
//  }
//
//// Returns any Ref
//// TODO: DOUBLE CHECK THIS
//// TODO: PROBABLY SHOULD POP STUFF
//procedure AppLocalGetEx();
//  requires StackPointer > 0;
//implementation AppLocalGetEx() {
//  //var value: Ref;
//  //var _: Ref;
//  //havoc value;
//  //call _ := Pop();
//  //call _ := Pop();
//  //call _ := Pop();
//  //call Push(value);
//  call Int(0);
//  }
//
//procedure AppGlobalGet();
//  requires StackPointer >= 0;
//  modifies Stack;
//  modifies StackPointer;
//implementation AppGlobalGet() {
//  var value: Ref;
//  var key: Ref;
//  value := zero;
//  call key := Pop();
//  if (GlobalsAlloc[key] == true) {
//    value := Globals[key];
//    }
//  call Push(value);
//  }
//
//procedure AppGlobalPut();
//  requires StackPointer > 0;
//  modifies Globals;
//  modifies GlobalsAlloc;
//  modifies Stack;
//  modifies StackPointer;
//implementation AppGlobalPut() {
//  var value: Ref;
//  var key: Ref;
//  call value := Pop();
//  call key := Pop();
//  // TODO: See how to manage errors
//  //if (GlobalsAlloc[key] == true && IsInt[Globals[key]] != IsInt[value]) {
//  //  // ERROR
//  //  }
//  //else {
//  //  Globals[key] := value;
//  //  }
//  GlobalsAlloc[key] := true;
//  Globals[key] := value;
//  }
//
//procedure Dup();
//  requires StackPointer >= 0;
//  modifies Stack;
//  modifies StackPointer;
//implementation Dup() {
//  call Push(Stack[StackPointer]);
//  }
//
//procedure Int(n: int);
//  requires n >= 0;
//  modifies IsInt;
//  modifies RefToInt;
//  modifies StackPointer;
//  modifies Stack;
//  modifies Alloc;
//implementation Int(n: int) {
//  var newRef: Ref;
//  call newRef := FreshRefGenerator();
//  IsInt[newRef] := true;
//  RefToInt[newRef] := n;
//  call Push(newRef);
//  }
//
//procedure Sum();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//  requires RefToInt[Stack[StackPointer]] >= 0;
//  requires RefToInt[Stack[StackPointer-1]] >= 0;
//  modifies IsInt;
//  modifies Alloc;
//  modifies StackPointer;
//  modifies Stack;
//  modifies RefToInt;
//implementation Sum() {
//  var aRef: Ref;
//  var bRef: Ref;
//  call aRef := Pop();
//  call bRef := Pop();
//  call Int(RefToInt[aRef] + RefToInt[bRef]);
//  }
//
//procedure Byte(ref : Ref);
//  requires ref != zero;
//  requires IsInt[ref] == false;
//  modifies Stack;
//  modifies StackPointer;
//  modifies Alloc;
//  modifies IsInt;
//implementation Byte(ref : Ref) {
//  call Push(ref);
//  }
//
//procedure Btoi();
//implementation Btoi() {
//  var top : Ref;
//  var n: int;
//  call top := Pop();
//  call Int(RefToInt[top]);
//}
//
//procedure Return();
//implementation Return(){
//  assert !IsInt[Stack[StackPointer]] || RefToInt[Stack[StackPointer]] > 0;
//}
//
//procedure GTxn(index:int, field: [Transaction] Ref);
//implementation GTxn(index: int, field: [Transaction] Ref) {
//  call Push(field[GroupTransaction[index]]);
//  }
//
//procedure Txn(field: [Transaction] Ref);
//implementation Txn(field: [Transaction] Ref) {
//  call GTxn(GroupIndex[CurrentTxn], field);
//  }
//
//procedure Txna(arrayField: [Transaction][int] Ref, index: int);
//  modifies Stack;
//  modifies StackPointer;
//implementation Txna(arrayField: [Transaction][int] Ref, index: int) {
//  call Push(arrayField[CurrentTxn][index]);
//  }
//
//procedure Equal();
//  requires StackPointer > 0;
//  requires Stack[StackPointer] == zero || Stack[StackPointer-1] == zero || IsInt[Stack[StackPointer]] == IsInt[Stack[StackPointer-1]];
//  modifies StackPointer;
//  modifies IsInt;
//  modifies RefToInt;
//  modifies Alloc;
//  modifies Stack;
//implementation Equal() {
//    var aRef: Ref;
//    var bRef: Ref;
//    call bRef := Pop();
//    call aRef := Pop();
//    if (aRef == bRef || (IsInt[aRef] && RefToInt[aRef] == RefToInt[bRef])) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure And();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation And() {
//    var aRef: Ref;
//    var bRef: Ref;
//    call bRef := Pop();
//    call aRef := Pop();
//    if (IsInt[aRef] && IsInt[bRef] && RefToInt[aRef] > 0 && RefToInt[bRef] > 0) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure Or();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation Or() {
//    var aRef: Ref;
//    var bRef: Ref;
//    call bRef := Pop();
//    call aRef := Pop();
//    if (IsInt[aRef] && IsInt[bRef] && (RefToInt[aRef] > 0 || RefToInt[bRef] > 0)) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure GreatOrEqual();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation GreatOrEqual() {
//    var aRef: Ref;
//    var bRef: Ref;
//    call bRef := Pop();
//    call aRef := Pop();
//    if (RefToInt[aRef] >= RefToInt[bRef]) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure LessOrEqual();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation LessOrEqual() {
//    var aRef: Ref;
//    var bRef: Ref;
//    call bRef := Pop();
//    call aRef := Pop();
//    if (RefToInt[aRef] <=  RefToInt[bRef]) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure AppOptedIn();
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation AppOptedIn() {
//    var applicationIDRef: Ref;
//    var accountsIndexRef: Ref;
//    var accountRef: Ref;
//    var applicationID: int;
//
//    call applicationIDRef := Pop();
//    call accountsIndexRef := Pop();
//
//    applicationID := RefToInt[applicationIDRef];
//    accountRef := Accounts[CurrentTxn][RefToInt[accountsIndexRef]];
//
//    if (OptedInApp[accountRef][applicationID] > 0) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//
//procedure AssetHoldingGet(field: [Ref][int]int);
//  requires StackPointer > 0;
//  requires IsInt[Stack[StackPointer]];
//  requires IsInt[Stack[StackPointer-1]];
//implementation AssetHoldingGet(field: [Ref][int]int) {
//    var assetIdRef: Ref;
//    var accountsIndexRef: Ref;
//    var accountRef: Ref;
//    var assetId: int;
//
//    call accountRef := FreshRefGenerator();
//    call assetIdRef := Pop();
//    call accountsIndexRef := Pop();
//
//    assetId := RefToInt[assetIdRef];
//    assert RefToInt[accountsIndexRef] == 0;
//    assert Accounts[CurrentTxn][0] == Sender[CurrentTxn];
//    assert Accounts[CurrentTxn][RefToInt[accountsIndexRef]] == Sender[CurrentTxn];
//    assert NotCreator == Sender[CurrentTxn];
//    accountRef := Accounts[CurrentTxn][RefToInt[accountsIndexRef]];
//    assert field[accountRef][assetId]>= 1;
//    call Int(field[accountRef][assetId]);
//    if (OptedInAsset[accountRef][assetId] > 0) {
//      call Int(1);
//      return;
//    }
//    call Int(0);
//    return;
//  }
//


procedure contract();
implementation contract() {
  var s0 : int;
  var s1 : int;
  var s2 : int;
  var s3 : int;
  var s4 : int;
  var s5 : int;
  var s6 : int;
  var s7 : int;
  var s8 : int;
  var s9 : int;
  var condition: bool
  s0 := 0;
  s1 := ApplicationID[GroupTransaction[GroupIndex[CurrentTxn]]];
  condition := s0 == s1;
  if (!condition) {
    goto not_creation;
  }
  s0 := creator;
  s1 := Sender[GroupTransaction[GroupIndex[CurrentTxn]]];
  Globals[s1] := s0;
  s0 := NumAppArgs[GroupTransaction[GroupIndex[CurrentTxn]]];
  s1 := 4;
  condition := s0 == s1
  if (!condition) {
    goto failed;
  }
  //call Byte(regBegin);
  s0 := regBegin;
  //call Txna(ApplicationArgs, 0);
  s1 := ApplicationArgs[GroupTransaction[GroupIndex[CurrentTxn]]][0];
  //call Btoi(); noop int this version. should err if it is not byte
  //call AppGlobalPut();
  Globals[s0] := s1;
  //call Byte(regEnd);
  //call Txna(ApplicationArgs, 1);
  //call Btoi();
  //call AppGlobalPut();
  s0 := regEnd;
  s1 := ApplicationArgs[GroupTransaction[GroupIndex[CurrentTxn]]][1];
  Globals[s0] := s1;
  //call Byte(voteBegin);
  //call Txna(ApplicationArgs, 2);
  //call Btoi();
  //call AppGlobalPut();
  s0 := voteBegin;
  s1 := ApplicationArgs[GroupTransaction[GroupIndex[CurrentTxn]]][2];
  Globals[s0] := s1;
  //call Byte(voteEnd);
  //call Txna(ApplicationArgs, 3);
  //call Btoi();
  //call AppGlobalPut();
  s0 := voteEnd;
  s1 := ApplicationArgs[GroupTransaction[GroupIndex[CurrentTxn]]][3];
  Globals[s0] := s1;
  //call Int(1);
  s0 := 1;
  //call Return();
  assert s0 > 0;
  return;
  not_creation:
  //  call Int(DeleteApplication);
    s0 := DeleteApplication;
  //  call Txn(OnCompletion);
    s1 := OnCompletion[GroupTransaction[GroupIndex[CurrentTxn]]];
  //  call Equal();
    if (s0 == s1) {
      s0 := 1;
    }
    else {
      s0 := 0;
    }
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto not_deletion;
  //  }
    if (s0 == 0) {
        goto not_deletion;
    }
  //  call Byte(creator);
    s0 := creator;
  //  call AppGlobalGet();
    s0 := Globals[s0];
  //  call Txn(Sender);
    s1 := Sender[GroupTransaction[GroupIndex[CurrentTxn]]];
  //  call Equal();
    if (s0 == s1) {
      s0 := 1;
    }
    else {
      s0 := 0;
    } //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
    if (s0 == 0) {
      goto failed;
    }
  //  call Int(1);
    s0 := 1;
    return;
  //  call Return();
  //  return;
  not_deletion:
   goto failed;
  //  call Int(UpdateApplication);
  //  call Txn(OnCompletion);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto not_update;
  //  }
  //  call Byte(creator);
  //  call AppGlobalGet();
  //  call Txn(Sender);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(1);
  //  call Return();
  //  return;
  //not_update:
  //  call Int(CloseOut);
  //  call Txn(OnCompletion);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
  //    goto close_out;
  //  }
  //  call Txna(ApplicationArgs,0);
  //  call Byte(register);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
  //    goto register;
  //  }
  //  call Txna(ApplicationArgs,0);
  //  call Byte(vote);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
  //    goto vote;
  //  }
  //  call Int(0);
  //  call Return();
  //  return;
  //vote:
  //  // global Round
  //  call Int(Round);
  //  call Byte(voteBegin);
  //  call AppGlobalGet();
  //  call GreatOrEqual();
  //  call Int(Round);
  //  assert voteEnd != zero;
  //  assert !IsInt[voteEnd];
  //  call Byte(voteEnd);
  //  call AppGlobalGet();
  //  call LessOrEqual();
  //  call And();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(0);
  //  call Txn(ApplicationID);
  //  call AppOptedIn();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(0);
  //  call Int(2);
  //  call AssetHoldingGet(AssetBalance);
  //  call _ := Pop();
  //  call Int(1);
  //  call GreatOrEqual();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(GroupSize);
  //  call Int(2);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call GTxn(1,TypeEnum);
  //  call Int(4);
  //  // TODO: should fail here
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Byte(creator);
  //  call AppGlobalGet();
  //  call GTxn(1,AssetReceiver);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call GTxn(1,XferAsset);
  //  call Int(2);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call GTxn(1,AssetAmount);
  //  call Int(1);
  //  call Equal();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(0);
  //  call Txn(ApplicationID);
  //  call Byte(voted);
  //  call AppLocalGetEx();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
  //    goto voted;
  //  }
  //  call _ := Pop();
  //  call Txna(ApplicationArgs, 1);
  //  call Byte(candidatea);
  //  call Equal();
  //  call Txna(ApplicationArgs, 1);
  //  call Byte(candidateb);
  //  call Equal();
  //  call Or();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(0);
  //  call Txna(ApplicationArgs,1);
  //  call AppGlobalGetEx();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
  //    goto increment_existing;
  //  }
  //  call _:= Pop();
  //  call Int(0);
  //increment_existing:
  //  call Int(1);
  //  call Sum();
  //  call Store(1);
  //  call Txna(ApplicationArgs,1);
  //  call Load(1);
  //  call AppGlobalPut();
  //  call Int(0);
  //  call Byte(voted);
  //  call Txna(ApplicationArgs,1);
  //  call AppGlobalPut();
  //  call Int(1);
  //  call Return();
  //  return;
  //voted:
  //  call _ := Pop();
  //  call Int(1);
  //  call Return();
  //  return;
  //register:
  //  call Int(Round);
  //  call Byte(regBegin);
  //  call AppGlobalGet();
  //  call GreatOrEqual();
  //  call Int(Round);
  //  call Byte(regEnd);
  //  call AppGlobalGet();
  //  call LessOrEqual();
  //  call And();
  //  call Int(OptIn);
  //  call Txn(OnCompletion);
  //  call Equal();
  //  call And();
  //  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
  //    goto failed;
  //  }
  //  call Int(1);
  //  call Return();
  //  return;
  //close_out:
  //  call Int(1);
  //  call Return();
  //  return;
  failed:
    s0 := 0;
    assert s0 == 1;
    return;
  }

procedure verify();
  requires GroupSize > 0;
  requires (forall txn: Transaction:: 0 <= GroupIndex[txn]);
  requires (forall txn: Transaction:: GroupIndex[txn] < GroupSize);
  requires (forall txn: Transaction:: GroupTransaction[GroupIndex[txn]] == txn);
  requires Accounts[CurrentTxn][0] == Sender[CurrentTxn];
  requires OptIn > 0;
  requires CloseOut > 0;
  requires DeleteApplication > 0;
  requires UpdateApplication > 0;
  requires StackPointer == -1;
implementation verify() {
  // get string refs
  //call creator := FreshRefGenerator();
  //call regBegin := FreshRefGenerator();
  //call regEnd := FreshRefGenerator();
  //call voteBegin := FreshRefGenerator();
  //call voteEnd := FreshRefGenerator();
  //call register := FreshRefGenerator();
  //call vote := FreshRefGenerator();
  //call voted := FreshRefGenerator();
  //call candidatea := FreshRefGenerator();
  //call candidateb := FreshRefGenerator();

  //assume IsInt[zero] == true;
  //assume RefToInt[zero] == 0;
  //assume Alloc[zero];
  //assume Alloc[Creator];
  //assume Alloc[NotCreator];
  //assume Alloc[AssetTransfer];
  //assume IsInt[AssetTransfer];
  //assume RefToInt[AssetTransfer] == 4;

  //assume Noop == 0;
  //assume OptIn == 1;
  //assume CloseOut == 2;
  //assume ClearState == 3;
  //assume UpdateApplication == 4;
  //assume DeleteApplication == 5;

  call verifyCreation();
  call verifyDeleteApplication();
  // call verifyUpdateApplication();
  // call verifyCloseOut();
  // call verifyRegister();
  //call verifyVote();
  assert false;
}

procedure verifyCreation();
implementation verifyCreation() {
  //var numAppArgs : Ref;
  //var onCompletion : Ref;
  //var applicationArgs0 : Ref;
  //var applicationArgs1 : Ref;
  //var applicationArgs2 : Ref;
  //var applicationArgs3 : Ref;
  //var applicationID : Ref;

  //call numAppArgs := FreshRefGenerator();
  //call applicationArgs0 := FreshRefGenerator();
  //call applicationArgs1 := FreshRefGenerator();
  //call applicationArgs2 := FreshRefGenerator();
  //call applicationArgs3 := FreshRefGenerator();
  //call applicationID := FreshRefGenerator();
  //call onCompletion := FreshRefGenerator();

  //IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := 0;

  Sender[CurrentTxn] := Creator;

  NumAppArgs[CurrentTxn] := 4;

  ApplicationArgs[CurrentTxn][0] := 42; // regBegin
  ApplicationArgs[CurrentTxn][1] := 42; // regEnd
  ApplicationArgs[CurrentTxn][2] := 42; // voteBegin
  ApplicationArgs[CurrentTxn][3] := 42; // voteEnd

  GroupSize := 1;
  call contract();
  assert Globals[regBegin] == 42;
  assert Globals[regEnd] == 42;
  assert Globals[voteBegin] == 42;
  assert Globals[voteEnd] == 42;
}

procedure verifyDeleteApplication();
implementation verifyDeleteApplication() {
  var applicationID : int;
  assume applicationID != 0;
  ApplicationID[CurrentTxn] := applicationID;

  Sender[CurrentTxn] := Creator;

  NumAppArgs[CurrentTxn] := 0;

  OnCompletion[CurrentTxn] := DeleteApplication;

  GroupSize := 1;
  call contract();
}

//procedure verifyUpdateApplication();
//implementation verifyUpdateApplication() {
//  var numAppArgs : Ref;
//  var onCompletion : Ref;
//  var applicationID : Ref;
//
//  call numAppArgs := FreshRefGenerator();
//  call applicationID := FreshRefGenerator();
//  call onCompletion := FreshRefGenerator();
//
//  IsInt[applicationID] := true;
//  ApplicationID[CurrentTxn] := applicationID;
//  assume RefToInt[ApplicationID[CurrentTxn]] != 0;
//
//  Sender[CurrentTxn] := Creator;
//
//  IsInt[numAppArgs] := true;
//  NumAppArgs[CurrentTxn] := numAppArgs;
//  RefToInt[NumAppArgs[CurrentTxn]] := 0;
//
//  IsInt[onCompletion] := true;
//  OnCompletion[CurrentTxn] := onCompletion;
//  RefToInt[OnCompletion[CurrentTxn]] := UpdateApplication;
//
//  GroupSize := 1;
//  call contract();
//}

//procedure verifyCloseOut();
//implementation verifyCloseOut() {
//  var numAppArgs : Ref;
//  var onCompletion : Ref;
//  var applicationID : Ref;
//
//  call numAppArgs := FreshRefGenerator();
//  call applicationID := FreshRefGenerator();
//  call onCompletion := FreshRefGenerator();
//
//  IsInt[applicationID] := true;
//  ApplicationID[CurrentTxn] := applicationID;
//  assume RefToInt[ApplicationID[CurrentTxn]] != 0;
//
//  Sender[CurrentTxn] := Creator;
//
//  IsInt[numAppArgs] := true;
//  NumAppArgs[CurrentTxn] := numAppArgs;
//  RefToInt[NumAppArgs[CurrentTxn]] := 0;
//
//  IsInt[onCompletion] := true;
//  OnCompletion[CurrentTxn] := onCompletion;
//  RefToInt[OnCompletion[CurrentTxn]] := CloseOut;
//
//  GroupSize := 1;
//  call contract();
//}
//
//procedure verifyRegister();
//implementation verifyRegister() {
//  var numAppArgs : Ref;
//  var onCompletion : Ref;
//  var applicationID : Ref;
//
//  call numAppArgs := FreshRefGenerator();
//  call applicationID := FreshRefGenerator();
//  call onCompletion := FreshRefGenerator();
//
//  IsInt[applicationID] := true;
//  ApplicationID[CurrentTxn] := applicationID;
//  assume RefToInt[ApplicationID[CurrentTxn]] != 0;
//
//  Sender[CurrentTxn] := NotCreator;
//
//  IsInt[numAppArgs] := true;
//  NumAppArgs[CurrentTxn] := numAppArgs;
//  RefToInt[NumAppArgs[CurrentTxn]] := 1;
//
//  IsInt[onCompletion] := true;
//  OnCompletion[CurrentTxn] := onCompletion;
//  RefToInt[OnCompletion[CurrentTxn]] := OptIn;
//
//  ApplicationArgs[CurrentTxn][0] := register;
//
//  assume RefToInt[Globals[regBegin]] >= Round;
//  assume RefToInt[Globals[regEnd]] <= Round;
//
//  GroupSize := 1;
//  call contract();
//}
//
//procedure verifyVote();
//implementation verifyVote() {
//  var numAppArgs : Ref;
//  var onCompletion : Ref;
//  var applicationID : Ref;
//  var hardcodedToken : Ref;
//  var assetAmount : Ref;
//
//  call numAppArgs := FreshRefGenerator();
//  call applicationID := FreshRefGenerator();
//  call onCompletion := FreshRefGenerator();
//  call hardcodedToken := FreshRefGenerator();
//  call assetAmount := FreshRefGenerator();
//
//  IsInt[applicationID] := true;
//  ApplicationID[CurrentTxn] := applicationID;
//  assume RefToInt[ApplicationID[CurrentTxn]] != 0;
//
//  Sender[CurrentTxn] := NotCreator;
//
//  IsInt[numAppArgs] := true;
//  NumAppArgs[CurrentTxn] := numAppArgs;
//  RefToInt[NumAppArgs[CurrentTxn]] := 2;
//
//  IsInt[onCompletion] := true;
//  OnCompletion[CurrentTxn] := onCompletion;
//  RefToInt[OnCompletion[CurrentTxn]] := OptIn;
//
//  ApplicationArgs[CurrentTxn][0] := vote;
//  ApplicationArgs[CurrentTxn][1] := candidatea;
//
//  assume RefToInt[Globals[voteBegin]] >= Round;
//  assume RefToInt[Globals[voteEnd]] <= Round;
//  assume OptedInApp[NotCreator][RefToInt[applicationID]] >  0;
//  assume AssetBalance[NotCreator][RefToInt[hardcodedToken]] >= 1;
//  assume Accounts[CurrentTxn][0] == Sender[CurrentTxn];
//  IsInt[hardcodedToken] := true;
//  assume RefToInt[hardcodedToken] == 2;
//
//  GroupSize := 2;
//  // TODO: implement 2nd tx
//
//  TypeEnum[GroupTransaction[1]] := AssetTransfer;
//  AssetReceiver[GroupTransaction[1]] := Creator;
//
//  XferAsset[GroupTransaction[1]] := hardcodedToken;
//
//  IsInt[assetAmount] := true;
//  RefToInt[assetAmount] := 1;
//  AssetAmount[GroupTransaction[1]] := assetAmount;
//
//  call contract();
//}
