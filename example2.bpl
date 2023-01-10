type Ref;
type Transaction;
const unique zero: Ref;

// TypeEnum constants
// These are configured on the 'verify' procedur. TODO: Configure all
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
var Globals: [Ref] Ref;
var GlobalsExAlloc: [Ref][Ref] bool;
var GlobalsEx: [Ref][Ref] Ref;
var LocalsAlloc: [Ref][Ref] bool;
var Locals: [Ref][Ref] Ref;
var LocalsExAlloc: [Ref][Ref][Ref] bool;
var LocalsEx: [Ref][Ref][Ref] Ref;
var ScratchSpace: [int] Ref;
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
var Sender : [Transaction] Ref;
var NumAppArgs : [Transaction] Ref;
var ApplicationArgs : [Transaction] [int] Ref;
var OnCompletion : [Transaction] Ref;
var Accounts : [Transaction] [int] Ref;
var ApplicationID : [Transaction] Ref;
var TypeEnum: [Transaction] Ref;
var AssetReceiver: [Transaction] Ref;
var XferAsset: [Transaction] Ref;
var AssetAmount: [Transaction] Ref;

const unique Creator : Ref;
const unique NotCreator : Ref;

var _: Ref;

// declare srings
var creator: Ref;
var regBegin: Ref;
var regEnd: Ref;
var voteBegin: Ref;
var voteEnd: Ref;
var register: Ref;
var vote: Ref;
var voted: Ref;
var candidatea: Ref;
var candidateb: Ref;

procedure FreshRefGenerator() returns (newRef: Ref);
  modifies Alloc;
  modifies IsInt;
  //ensures old(Alloc[newRef] == false);
  //ensures Alloc[newRef] == true;
  //ensures newRef != zero;
  //ensures IsInt[newRef] == false;
  //ensures (forall ref: Ref :: ref != newRef ==> IsInt[ref] == old(IsInt[ref]));
  //ensures (forall ref: Ref :: ref != newRef ==> Alloc[ref] == old(Alloc[ref]));
implementation FreshRefGenerator() returns (newRef: Ref) {
    havoc newRef;
    assume Alloc[newRef] == false;
    Alloc[newRef] := true;
    IsInt[newRef] := false;
    assume newRef != zero;
  }

procedure Push(value: Ref);
  modifies Stack;
  modifies StackPointer;
  //ensures old(StackPointer) + 1 == StackPointer;
  //ensures Stack[StackPointer] == value;
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Push(value: Ref) {
  StackPointer := StackPointer + 1;
  Stack[StackPointer] := value;
  }

procedure Pop() returns (top: Ref);
  requires StackPointer >= 0;
  modifies StackPointer;
  //ensures StackPointer == old(StackPointer) - 1;
  //ensures top == old(Stack[old(StackPointer)]);
implementation Pop() returns (top: Ref){
  top := Stack[StackPointer];
  StackPointer := StackPointer - 1;
  }

procedure Store(i: int);
  requires 0 <= i ;
  requires i < 64;
  requires StackPointer >= 0;
  modifies ScratchSpace;
  modifies ScratchSpaceAlloc;
  modifies Stack;
  modifies StackPointer;
  //ensures ScratchSpaceAlloc[i] == true;
  //ensures ScratchSpace[i] == Stack[old(StackPointer)];
  //ensures StackPointer == old(StackPointer) - 1;
  //ensures (forall j: int:: -1 <= j && j <= StackPointer ==> Stack[j] == old(Stack[j]));
  //ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpace[j] == old(ScratchSpace[j]));
  //ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpaceAlloc[j] == old(ScratchSpaceAlloc[j]));
implementation Store(i: int) {
  var value: Ref;
  call value := Pop();
  ScratchSpaceAlloc[i] := true;
  ScratchSpace[i] := value;
  }

procedure Load(i: int);
  requires 0 <= i ;
  requires i < 64;
  requires ScratchSpaceAlloc[i] == true;
  modifies Stack;
  modifies StackPointer;
  //ensures Stack[StackPointer] == ScratchSpace[i];
  //ensures StackPointer == old(StackPointer)+1;
  //ensures (forall j: int:: -1 <= j && j < StackPointer ==> Stack[j] == old(Stack[j]));
  //ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpaceAlloc[j] == old(ScratchSpaceAlloc[j]));
implementation Load(i: int) {
  call Push(ScratchSpace[i]);
  }

// Returns any Ref
procedure AppGlobalGetEx();
  requires StackPointer > 0;
implementation AppGlobalGetEx() {
  //var value: Ref;
  //var _: Ref;
  //havoc value;
  //call _ := Pop();
  //call _ := Pop();
  //call Push(value);
  call Int(1);
  }

// Returns any Ref
procedure AppLocalGetEx();
  requires StackPointer > 0;
implementation AppLocalGetEx() {
  //var value: Ref;
  //var _: Ref;
  //havoc value;
  //call _ := Pop();
  //call _ := Pop();
  //call _ := Pop();
  //call Push(value);
  call Int(0);
  }

procedure AppGlobalGet();
  requires StackPointer >= 0;
  modifies Stack;
  modifies StackPointer;
  //ensures (GlobalsAlloc[old(Stack)[old(StackPointer)]] == true && Stack[StackPointer] == Globals[old(Stack)[old(StackPointer)]]) || Stack[StackPointer] == zero;
  //ensures StackPointer == old(StackPointer);
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation AppGlobalGet() {
  var value: Ref;
  var key: Ref;
  value := zero;
  call key := Pop();
  if (GlobalsAlloc[key] == true) {
    value := Globals[key]; 
    }
  call Push(value);
  }

procedure AppGlobalPut();
  requires StackPointer > 0;
  modifies Globals;
  modifies GlobalsAlloc;
  modifies Stack;
  modifies StackPointer;
  //ensures GlobalsAlloc[old(Stack[old(StackPointer)-1])] == true;
  //ensures Globals[old(Stack[old(StackPointer)-1])] == old(Stack[old(StackPointer)]);
  //ensures StackPointer == old(StackPointer) - 2;
  //ensures (forall i: int:: -1 <= i && i <= StackPointer ==> Stack[i] == old(Stack[i]));
  //ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)-1]) ==> Globals[ref] == old(Globals[ref]));
  //ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)-1]) ==> GlobalsAlloc[ref] == old(GlobalsAlloc[ref]));
implementation AppGlobalPut() {
  var value: Ref;
  var key: Ref;
  call value := Pop();
  call key := Pop();
  // TODO: See how to manage errors
  //if (GlobalsAlloc[key] == true && IsInt[Globals[key]] != IsInt[value]) {
  //  // ERROR
  //  }
  //else {
  //  Globals[key] := value;
  //  }
  GlobalsAlloc[key] := true;
  Globals[key] := value;
  }

procedure Dup();
  requires StackPointer >= 0;
  modifies Stack;
  modifies StackPointer;
  //ensures Stack[old(StackPointer)] == old(Stack[old(StackPointer)]);
  //ensures Stack[StackPointer] == old(Stack[old(StackPointer)]);
  //ensures StackPointer == old(StackPointer) + 1;
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Dup() {
  call Push(Stack[StackPointer]);
  }

procedure Int(n: int);
  requires n >= 0;
  modifies IsInt;
  modifies RefToInt;
  modifies StackPointer;
  modifies Stack;
  modifies Alloc;
  //ensures IsInt[Stack[StackPointer]];
  //ensures RefToInt[Stack[StackPointer]] == n;
  //ensures StackPointer == old(StackPointer) + 1;
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  //ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  //ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> IsInt[ref] == old(IsInt[ref]));
  //ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> Alloc[ref] == old(Alloc[ref]));
implementation Int(n: int) {
  var newRef: Ref;
  call newRef := FreshRefGenerator();
  IsInt[newRef] := true;
  RefToInt[newRef] := n;
  call Push(newRef);
  }

procedure Sum();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
  requires RefToInt[Stack[StackPointer]] >= 0;
  requires RefToInt[Stack[StackPointer-1]] >= 0;
  modifies IsInt;
  modifies Alloc;
  modifies StackPointer;
  modifies Stack;
  modifies RefToInt;
  //ensures RefToInt[Stack[StackPointer]] == old(RefToInt[old(Stack[old(StackPointer)])]) + old(RefToInt[old(Stack[old(StackPointer)-1])]);
  //ensures StackPointer == old(StackPointer) - 1;
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  //ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer)-1]) && ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  //ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer)-1]) && ref != Stack[StackPointer] ==> IsInt[ref] == old(IsInt[ref]));
implementation Sum() {
  var aRef: Ref;
  var bRef: Ref;
  call aRef := Pop();
  call bRef := Pop();
  call Int(RefToInt[aRef] + RefToInt[bRef]);
  }

procedure Byte(ref : Ref);
  requires ref != zero;
  requires IsInt[ref] == false;
  modifies Stack;
  modifies StackPointer;
  modifies Alloc;
  modifies IsInt;
  //ensures IsInt[ref] == false;
  //ensures Stack[StackPointer] == ref;
  //ensures StackPointer == old(StackPointer) + 1;
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  //ensures (forall ref': Ref:: ref != ref' ==> IsInt[ref'] == old(IsInt[ref']));
  //ensures (forall ref': Ref:: ref != ref' ==> Alloc[ref'] == old(Alloc[ref']));
implementation Byte(ref : Ref) {
  call Push(ref);
  }

procedure Btoi();
implementation Btoi() {
  var top : Ref;
  var n: int;
  call top := Pop();
  call Int(RefToInt[top]);
}

procedure Return();
implementation Return(){
  assert !IsInt[Stack[StackPointer]] || RefToInt[Stack[StackPointer]] > 0;
}

procedure GTxn(index:int, field: [Transaction] Ref);
implementation GTxn(index: int, field: [Transaction] Ref) {
  call Push(field[GroupTransaction[index]]);
  }

procedure Txn(field: [Transaction] Ref);
implementation Txn(field: [Transaction] Ref) {
  call GTxn(GroupIndex[CurrentTxn], field);
  }

procedure Txna(arrayField: [Transaction][int] Ref, index: int);
  modifies Stack;
  modifies StackPointer;
  //ensures StackPointer == old(StackPointer) + 1;
  //ensures Stack[StackPointer] == arrayField[CurrentTxn][index];
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Txna(arrayField: [Transaction][int] Ref, index: int) {
  call Push(arrayField[CurrentTxn][index]);
  }

procedure Equal();
  requires StackPointer > 0;
  requires Stack[StackPointer] == zero || Stack[StackPointer-1] == zero || IsInt[Stack[StackPointer]] == IsInt[Stack[StackPointer-1]];
  modifies StackPointer;
  modifies IsInt;
  modifies RefToInt;
  modifies Alloc;
  modifies Stack;
  //ensures StackPointer == old(StackPointer-1);
  //ensures IsInt[Stack[StackPointer]];
  //ensures RefToInt[Stack[StackPointer]] == 1 || RefToInt[Stack[StackPointer]] == 0;
  //ensures old(Stack[StackPointer]) == old(Stack[StackPointer-1]) ==> RefToInt[Stack[StackPointer]] == 1;
  //ensures old(IsInt[Stack[StackPointer]]) && old(IsInt[Stack[StackPointer-1]]) && old(RefToInt[Stack[StackPointer]]) == old(RefToInt[Stack[StackPointer-1]]) ==> RefToInt[Stack[StackPointer]] == 1;
  //ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> IsInt[ref'] == old(IsInt[ref']));
  //ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> RefToInt[ref'] == old(RefToInt[ref']));
  //ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> Alloc[ref'] == old(Alloc[ref']));
  //ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Equal() {
    var aRef: Ref;
    var bRef: Ref;
    call bRef := Pop();
    call aRef := Pop();
    if (aRef == bRef || (IsInt[aRef] && RefToInt[aRef] == RefToInt[bRef])) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure And();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation And() {
    var aRef: Ref;
    var bRef: Ref;
    call bRef := Pop();
    call aRef := Pop();
    if (IsInt[aRef] && IsInt[bRef] && RefToInt[aRef] > 0 && RefToInt[bRef] > 0) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure Or();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation Or() {
    var aRef: Ref;
    var bRef: Ref;
    call bRef := Pop();
    call aRef := Pop();
    if (IsInt[aRef] && IsInt[bRef] && (RefToInt[aRef] > 0 || RefToInt[bRef] > 0)) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure GreatOrEqual();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation GreatOrEqual() {
    var aRef: Ref;
    var bRef: Ref;
    call bRef := Pop();
    call aRef := Pop();
    if (RefToInt[aRef] >= RefToInt[bRef]) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure LessOrEqual();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation LessOrEqual() {
    var aRef: Ref;
    var bRef: Ref;
    call bRef := Pop();
    call aRef := Pop();
    if (RefToInt[aRef] <=  RefToInt[bRef]) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure AppOptedIn();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation AppOptedIn() {
    var applicationIDRef: Ref;
    var accountsIndexRef: Ref;
    var accountRef: Ref;
    var applicationID: int;

    call applicationIDRef := Pop();
    call accountsIndexRef := Pop();

    applicationID := RefToInt[applicationIDRef];
    accountRef := Accounts[CurrentTxn][RefToInt[accountsIndexRef]];

    if (OptedInApp[accountRef][applicationID] > 0) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure AssetHoldingGet(field: [Ref][int]int);
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer-1]];
implementation AssetHoldingGet(field: [Ref][int]int) {
    var assetIdRef: Ref;
    var accountsIndexRef: Ref;
    var accountRef: Ref;
    var assetId: int;

    call accountRef := FreshRefGenerator();
    call assetIdRef := Pop();
    call accountsIndexRef := Pop();
    
    assetId := RefToInt[assetIdRef];
    assert RefToInt[accountsIndexRef] == 0;
    assert Accounts[CurrentTxn][0] == Sender[CurrentTxn];
    assert Accounts[CurrentTxn][RefToInt[accountsIndexRef]] == Sender[CurrentTxn];
    assert NotCreator == Sender[CurrentTxn];
    accountRef := Accounts[CurrentTxn][RefToInt[accountsIndexRef]];
    assert field[accountRef][assetId]>= 1;
    call Int(field[accountRef][assetId]);
    if (OptedInAsset[accountRef][assetId] > 0) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }



procedure contract();
implementation contract() {

  // contract starts
  call Int(0);
  call Txn(ApplicationID);
  call Equal();
  // bz label === if RefToInt(stack[stackpoint]) == 0 gotolabel
  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
    goto not_creation;
  }
  call Byte(creator);
  call Txn(Sender);
  call AppGlobalPut();
  call Txn(NumAppArgs);
  call Int(4);
  call Equal();
  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
    goto failed;
  }
  call Byte(regBegin);
  call Txna(ApplicationArgs, 0);
  call Btoi();
  call AppGlobalPut();
  call Byte(regEnd);
  call Txna(ApplicationArgs, 1);
  call Btoi();
  call AppGlobalPut();
  call Byte(voteBegin);
  call Txna(ApplicationArgs, 2);
  call Btoi();
  call AppGlobalPut();
  call Byte(voteEnd);
  call Txna(ApplicationArgs, 3);
  call Btoi();
  call AppGlobalPut();
  call Int(1);
  call Return();
  return;
  not_creation:
    call Int(DeleteApplication);
    call Txn(OnCompletion);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto not_deletion; 
    }
    call Byte(creator);
    call AppGlobalGet();
    call Txn(Sender);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(1);
    call Return();
    return;
  not_deletion:
    call Int(UpdateApplication);
    call Txn(OnCompletion);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto not_update;
    }
    call Byte(creator);
    call AppGlobalGet();
    call Txn(Sender);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(1);
    call Return();
    return;
  not_update:
    call Int(CloseOut);
    call Txn(OnCompletion);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto close_out;
    }
    call Txna(ApplicationArgs,0);
    call Byte(register);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto register;
    }
    call Txna(ApplicationArgs,0);
    call Byte(vote);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto vote;
    }
    call Int(0);
    call Return();
    return;
  vote:
    // global Round
    call Int(Round);
    call Byte(voteBegin);
    call AppGlobalGet();
    call GreatOrEqual();
    call Int(Round);
    assert voteEnd != zero;
    assert !IsInt[voteEnd];
    call Byte(voteEnd);
    call AppGlobalGet();
    call LessOrEqual();
    call And();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Txn(ApplicationID);
    call AppOptedIn();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Int(2);
    call AssetHoldingGet(AssetBalance);
    call _ := Pop();
    call Int(1);
    call GreatOrEqual();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(GroupSize);
    call Int(2);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    // TODO: should fail here
    call GTxn(1,TypeEnum);
    call Int(4);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Byte(creator);
    call AppGlobalGet();
    call GTxn(1,AssetReceiver);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call GTxn(1,XferAsset);
    call Int(2);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call GTxn(1,AssetAmount);
    call Int(1);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Txn(ApplicationID);
    call Byte(voted);
    call AppLocalGetEx();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto voted;
    }
    call _ := Pop();
    call Txna(ApplicationArgs, 1);
    call Byte(candidatea);
    call Equal();
    call Txna(ApplicationArgs, 1);
    call Byte(candidateb);
    call Equal();
    call Or();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Txna(ApplicationArgs,1);
    call AppGlobalGetEx();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto increment_existing;
    }
    call _:= Pop();
    call Int(0);
  increment_existing:
    call Int(1);
    call Sum();
    call Store(1);
    call Txna(ApplicationArgs,1);
    call Load(1);
    call AppGlobalPut();
    call Int(0);
    call Byte(voted);
    call Txna(ApplicationArgs,1);
    call AppGlobalPut();
    call Int(1);
    call Return();
    return;
  voted:
    call _ := Pop();
    call Int(1);
    call Return();
    return;
  register:
    call Int(Round);
    call Byte(regBegin);
    call AppGlobalGet();
    call GreatOrEqual();
    call Int(Round);
    call Byte(regEnd);
    call AppGlobalGet();
    call LessOrEqual();
    call And();
    call Int(OptIn);
    call Txn(OnCompletion);
    call Equal();
    call And();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(1);
    call Return();
    return;
  close_out:
    call Int(1);
    call Return();
    return;
  failed:
    call Int(0);
    call Return();
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
  call creator := FreshRefGenerator();
  call regBegin := FreshRefGenerator();
  call regEnd := FreshRefGenerator();
  call voteBegin := FreshRefGenerator();
  call voteEnd := FreshRefGenerator();
  call register := FreshRefGenerator();
  call vote := FreshRefGenerator();
  call voted := FreshRefGenerator();
  call candidatea := FreshRefGenerator();
  call candidateb := FreshRefGenerator();

  assume IsInt[zero] == true;
  assume RefToInt[zero] == 0;
  assume Alloc[zero];
  assume Alloc[Creator];
  assume Alloc[NotCreator];
  assume Alloc[AssetTransfer];
  assume IsInt[AssetTransfer];
  assume RefToInt[AssetTransfer] == 4;

  assume Noop == 0;
  assume OptIn == 1;
  assume CloseOut == 2;
  assume ClearState == 3;
  assume UpdateApplication == 4;
  assume DeleteApplication == 5;

  call verifyCreation();
  // call verifyDeleteApplication();
  // call verifyUpdateApplication();
  // call verifyCloseOut();
  // call verifyRegister();
  call verifyVote();
  assert false;
}

procedure verifyCreation();
implementation verifyCreation() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationArgs0 : Ref;
  var applicationArgs1 : Ref;
  var applicationArgs2 : Ref;
  var applicationArgs3 : Ref;
  var applicationID : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationArgs0 := FreshRefGenerator();
  call applicationArgs1 := FreshRefGenerator();
  call applicationArgs2 := FreshRefGenerator();
  call applicationArgs3 := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  RefToInt[ApplicationID[CurrentTxn]] := 0;

  Sender[CurrentTxn] := Creator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 4;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;

  ApplicationArgs[CurrentTxn][0] := applicationArgs0; // regBegin
  RefToInt[ApplicationArgs[CurrentTxn][0]] := 42;
  ApplicationArgs[CurrentTxn][1] := applicationArgs1; // regEnd
  RefToInt[ApplicationArgs[CurrentTxn][1]] := 42;
  ApplicationArgs[CurrentTxn][2] := applicationArgs2; // voteBegin
  RefToInt[ApplicationArgs[CurrentTxn][2]] := 42;
  ApplicationArgs[CurrentTxn][3] := applicationArgs3; // voteEnd
  RefToInt[ApplicationArgs[CurrentTxn][3]] := 42;
   
  GroupSize := 1;
  call contract();
}

procedure verifyDeleteApplication();
implementation verifyDeleteApplication() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationID : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  Sender[CurrentTxn] := Creator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 0;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;
  RefToInt[OnCompletion[CurrentTxn]] := DeleteApplication;

  GroupSize := 1;
  call contract();
}

procedure verifyUpdateApplication();
implementation verifyUpdateApplication() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationID : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  Sender[CurrentTxn] := Creator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 0;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;
  RefToInt[OnCompletion[CurrentTxn]] := UpdateApplication;

  GroupSize := 1;
  call contract();
}

procedure verifyCloseOut();
implementation verifyCloseOut() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationID : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  Sender[CurrentTxn] := Creator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 0;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;
  RefToInt[OnCompletion[CurrentTxn]] := CloseOut;

  GroupSize := 1;
  call contract();
}

procedure verifyRegister();
implementation verifyRegister() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationID : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  Sender[CurrentTxn] := NotCreator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 1;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;
  RefToInt[OnCompletion[CurrentTxn]] := OptIn;

  ApplicationArgs[CurrentTxn][0] := register;

  assume RefToInt[Globals[regBegin]] >= Round;
  assume RefToInt[Globals[regEnd]] <= Round;

  GroupSize := 1;
  call contract();
}

procedure verifyVote();
implementation verifyVote() {
  var numAppArgs : Ref;
  var onCompletion : Ref;
  var applicationID : Ref;
  var hardcodedToken : Ref;
  var assetAmount : Ref;

  call numAppArgs := FreshRefGenerator();
  call applicationID := FreshRefGenerator();
  call onCompletion := FreshRefGenerator();
  call hardcodedToken := FreshRefGenerator();
  call assetAmount := FreshRefGenerator();

  IsInt[applicationID] := true;
  ApplicationID[CurrentTxn] := applicationID;
  assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  Sender[CurrentTxn] := NotCreator;
  
  IsInt[numAppArgs] := true;
  NumAppArgs[CurrentTxn] := numAppArgs;
  RefToInt[NumAppArgs[CurrentTxn]] := 2;

  IsInt[onCompletion] := true;
  OnCompletion[CurrentTxn] := onCompletion;
  RefToInt[OnCompletion[CurrentTxn]] := OptIn;

  ApplicationArgs[CurrentTxn][0] := vote;
  ApplicationArgs[CurrentTxn][1] := candidatea;

  assume RefToInt[Globals[voteBegin]] >= Round;
  assume RefToInt[Globals[voteEnd]] <= Round;
  assume OptedInApp[NotCreator][RefToInt[applicationID]] >  0;
  assume AssetBalance[NotCreator][RefToInt[hardcodedToken]] >= 1;
  assume Accounts[CurrentTxn][0] == Sender[CurrentTxn];
  assume RefToInt[hardcodedToken] == 2;

  GroupSize := 2;
  // TODO: implement 2nd tx
  call contract();

  //var numAppArgs : Ref;
  //var onCompletion : Ref;
  //var applicationID : Ref;
  //var hardcodedToken: Ref;
  //var assetAmount: Ref;

  //GroupSize := 2;
  //GroupIndex[CurrentTxn] := 0;
  //GroupTransaction[0] := CurrentTxn;

  //call numAppArgs := FreshRefGenerator();
  //call applicationID := FreshRefGenerator();
  //call onCompletion := FreshRefGenerator();
  //call hardcodedToken := FreshRefGenerator();
  //call assetAmount := FreshRefGenerator();
 
  //// first tx
  //IsInt[applicationID] := true;
  //ApplicationID[CurrentTxn] := applicationID;
  //assume RefToInt[ApplicationID[CurrentTxn]] != 0;

  //Sender[CurrentTxn] := NotCreator;
  //
  //IsInt[numAppArgs] := true;
  //NumAppArgs[CurrentTxn] := numAppArgs;
  //RefToInt[NumAppArgs[CurrentTxn]] := 1;

  //IsInt[onCompletion] := true;
  //OnCompletion[CurrentTxn] := onCompletion;
  //RefToInt[OnCompletion[CurrentTxn]] := OptIn;

  //ApplicationArgs[CurrentTxn][0] := vote;
  //ApplicationArgs[CurrentTxn][1] := candidatea;

  //assume RefToInt[Globals[voteBegin]] >= Round;
  //assume RefToInt[Globals[voteEnd]] <= Round;
  //assume OptedInApp[NotCreator][RefToInt[applicationID]] >  0;
  //assume AssetBalance[NotCreator][RefToInt[hardcodedToken]] > 0;

  ////// second tx
  ////TypeEnum[GroupTransaction[1]] := AssetTransfer;

  ////AssetReceiver[GroupTransaction[1]] := Creator;

  ////IsInt[hardcodedToken] := true;
  ////RefToInt[hardcodedToken] := 2;
  ////XferAsset[GroupTransaction[1]] := hardcodedToken;

  ////IsInt[assetAmount] := true;
  ////RefToInt[assetAmount] := 1;
  ////AssetAmount[GroupTransaction[1]] := assetAmount;

  //call contract();
}
