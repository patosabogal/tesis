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

procedure Multiply();
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
implementation Multiply() {
  var aRef: Ref;
  var bRef: Ref;
  call aRef := Pop();
  call bRef := Pop();
  call Int(RefToInt[aRef] * RefToInt[bRef]);
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
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	call Int(12);
	call Dup();
	call Multiply();
	call Store(1);
	call Int(10);
	call Dup();
	call Multiply();
	call Load(1);
	call Sum();
	call Int(244);
	call Equal();
	assert false;
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
  assume IsInt[zero] == true;
  assume RefToInt[zero] == 0;
  assume Alloc[zero];
	call contract();
}
