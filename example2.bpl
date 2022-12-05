type Ref;
type Field a;
const unique zero: Ref;
const unique OptIn: int;
const unique Noop : int;
const unique CloseOut: int;
const unique DeleteApplication: int;
const unique UpdateApplication: int;
var Alloc: [Ref] bool;
var Globals: [Ref] Ref;
var GlobalsAlloc: [Ref] bool;
var ScratchSpace: [int] Ref;
var ScratchSpaceAlloc: [int] bool;
var StackPointer: int;
var Stack: [int] Ref;
var IsInt: [Ref] bool;
var RefToInt: [Ref] int;

const unique GlobalRound: int;


// Modeling txns as refs
var CurrentTxn: Ref;
var Sender : [Ref] Ref;
var NumAppArgs : [Ref] Ref;
var ApplicationArgs : [Ref] [int] Ref;
var OnCompletion : [Ref] Ref;
var Accounts : [Ref] [int] Ref;
var GroupTransaction: [Ref] [int] Ref;
var ApplicationID : [Ref] Ref;
var TypeEnum: [Ref] Ref;
var AssetReceiver: [Ref] Ref;
var XferAsset: [Ref] Ref;
var AssetAmount: [Ref] Ref;

procedure FreshRefGenerator() returns (newRef: Ref);
  modifies Alloc;
  modifies IsInt;
  ensures old(Alloc[newRef] == false);
  ensures Alloc[newRef] == true;
  ensures newRef != zero;
  ensures IsInt[newRef] == false;
  ensures (forall ref: Ref :: ref != newRef ==> IsInt[ref] == old(IsInt[ref]));
  ensures (forall ref: Ref :: ref != newRef ==> Alloc[ref] == old(Alloc[ref]));
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
  ensures old(StackPointer) + 1 == StackPointer;
  ensures Stack[StackPointer] == value;
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Push(value: Ref) {
  StackPointer := StackPointer + 1;
  Stack[StackPointer] := value;
  }

procedure Pop() returns (top: Ref);
  requires StackPointer >= 0;
  modifies StackPointer;
  ensures StackPointer == old(StackPointer) - 1;
  ensures top == old(Stack[old(StackPointer)]);
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
  ensures ScratchSpaceAlloc[i] == true;
  ensures ScratchSpace[i] == Stack[old(StackPointer)];
  ensures StackPointer == old(StackPointer) - 1;
  ensures (forall j: int:: -1 <= j && j <= StackPointer ==> Stack[j] == old(Stack[j]));
  ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpace[j] == old(ScratchSpace[j]));
  ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpaceAlloc[j] == old(ScratchSpaceAlloc[j]));
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
  ensures Stack[StackPointer] == ScratchSpace[i];
  ensures StackPointer == old(StackPointer)+1;
  ensures (forall j: int:: -1 <= j && j < StackPointer ==> Stack[j] == old(Stack[j]));
  ensures (forall j: int:: 0 < j && j < 64 && i != j ==> ScratchSpaceAlloc[j] == old(ScratchSpaceAlloc[j]));
implementation Load(i: int) {
  call Push(ScratchSpace[i]);
  }

procedure AppGlobalGet();
  requires StackPointer >= 0;
  modifies Stack;
  modifies StackPointer;
  ensures (GlobalsAlloc[old(Stack)[old(StackPointer)]] == true && Stack[StackPointer] == Globals[old(Stack)[old(StackPointer)]]) || Stack[StackPointer] == zero;
  ensures StackPointer == old(StackPointer);
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures GlobalsAlloc[old(Stack[old(StackPointer)-1])] == true;
  ensures Globals[old(Stack[old(StackPointer)-1])] == old(Stack[old(StackPointer)]);
  ensures StackPointer == old(StackPointer) - 2;
  ensures (forall i: int:: -1 <= i && i <= StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)-1]) ==> Globals[ref] == old(Globals[ref]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)-1]) ==> GlobalsAlloc[ref] == old(GlobalsAlloc[ref]));
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
  ensures Stack[old(StackPointer)] == old(Stack[old(StackPointer)]);
  ensures Stack[StackPointer] == old(Stack[old(StackPointer)]);
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures IsInt[Stack[StackPointer]];
  ensures RefToInt[Stack[StackPointer]] == n;
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> IsInt[ref] == old(IsInt[ref]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> Alloc[ref] == old(Alloc[ref]));
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
  ensures RefToInt[Stack[StackPointer]] == old(RefToInt[old(Stack[old(StackPointer)])]) + old(RefToInt[old(Stack[old(StackPointer)-1])]);
  ensures StackPointer == old(StackPointer) - 1;
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer)-1]) && ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer)-1]) && ref != Stack[StackPointer] ==> IsInt[ref] == old(IsInt[ref]));
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
  ensures IsInt[ref] == false;
  ensures Stack[StackPointer] == ref;
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref': Ref:: ref != ref' ==> IsInt[ref'] == old(IsInt[ref']));
  ensures (forall ref': Ref:: ref != ref' ==> Alloc[ref'] == old(Alloc[ref']));
implementation Byte(ref : Ref) {
  call Push(ref);
  }

procedure Btoi();
implementation Btoi() {
  var top : Ref;
  call top := Pop();
  call Int(RefToInt[top]);
}

procedure Return();
  requires !IsInt[Stack[StackPointer]] || RefToInt[Stack[StackPointer]] > 0;
implementation Return(){}

procedure Txn(field: [Ref] Ref);
  modifies Stack;
  modifies StackPointer;
  ensures StackPointer == old(StackPointer) + 1;
  ensures Stack[StackPointer] == field[CurrentTxn];
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Txn(field: [Ref] Ref) {
  call Push(field[CurrentTxn]);
  }

procedure Txna(arrayField: [Ref][int] Ref, index: int);
  modifies Stack;
  modifies StackPointer;
  ensures StackPointer == old(StackPointer) + 1;
  ensures Stack[StackPointer] == arrayField[CurrentTxn][index];
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Txna(arrayField: [Ref][int] Ref, index: int) {
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
  ensures StackPointer == old(StackPointer-1);
  ensures IsInt[Stack[StackPointer]];
  ensures RefToInt[Stack[StackPointer]] == 1 || RefToInt[Stack[StackPointer]] == 0;
  ensures old(Stack[StackPointer]) == old(Stack[StackPointer-1]) ==> RefToInt[Stack[StackPointer]] == 1;
  ensures old(IsInt[Stack[StackPointer]]) && old(IsInt[Stack[StackPointer-1]]) && old(RefToInt[Stack[StackPointer]]) == old(RefToInt[Stack[StackPointer-1]]) ==> RefToInt[Stack[StackPointer]] == 1;
  ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> IsInt[ref'] == old(IsInt[ref']));
  ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> RefToInt[ref'] == old(RefToInt[ref']));
  ensures (forall ref': Ref:: Stack[StackPointer] != ref' ==> Alloc[ref'] == old(Alloc[ref']));
  ensures (forall i: int:: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Equal() {
    var aRef: Ref;
    var bRef: Ref;
    call aRef := Pop();
    call bRef := Pop();
    if (aRef == bRef || (IsInt[aRef] && RefToInt[aRef] == RefToInt[bRef])) {
      call Int(1);
      return;
    }
    call Int(0);
    return;
  }

procedure contract();
  requires StackPointer == -1;
  requires (forall ref: Ref:: IsInt[ref] == false);
  requires (forall ref: Ref:: GlobalsAlloc[ref] == false);
  requires (forall ref: Ref:: Alloc[ref] == false);
  requires (forall i: int:: ScratchSpaceAlloc[i] == false);
  requires (forall i: int:: Stack[i] == zero);
  modifies Alloc;
  modifies ScratchSpace;
  modifies ScratchSpaceAlloc;
  modifies Stack;
  modifies StackPointer;
  modifies IsInt;
  modifies Globals;
  modifies GlobalsAlloc;
  modifies RefToInt;
  modifies ApplicationID;

implementation contract() {
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

  // initial configuration
  // TODO: move to verify()
  IsInt[zero] := true;
  RefToInt[zero] := 0;
  ApplicationID[CurrentTxn] := zero;

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

  // contract starts
  assert Stack[StackPointer] != creator ;
  call Int(0);
  assert Stack[StackPointer] != creator ;
  call Txn(ApplicationID);
  call Equal();
  // bz label === if RefToInt(stack[stackpoint]) == 0 gotolabel
  if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
    goto not_creation;
  }
  call Byte(creator);
  call Txn(Sender);
  call AppGlobalPut();
  assume IsInt[NumAppArgs[CurrentTxn]] == true;
  assume RefToInt[NumAppArgs[CurrentTxn]] == 4;
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
    call Equal()
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
    call Byte(register)
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto register;
    }
    call Txna(ApplicationArgs,0);
    call Byte(vote)
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] != 0) {
      goto vote;
    }
    call Int(0);
    call Return();
    call return;
  vote:
    // global Round
    call Int(GlobalRound);
    call Byte(voteBegin);
    call AppGlobalGet();
    call GreatOrEqual() // TODO: Implement
    call Int(GlobalRound);
    call Byte(voteEnd);
    call LessOrEqual(); // TODO: Implement
    call And(); // TODO: Implement
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Txn(ApplicationID);
    call AppOptedIn(); // TODO: Implement
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Int(2);
    call AssetHoldingGet(AssetBalance); // TODO: Implement
    call _ := call Pop();
    call Int(1);
    call GreatOrEqual();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(GroupSize); // TODO: Implement
    call Int(2);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call GTxn(1,TypeEnum); // TODO: Implement
    call Int(4);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Byte(creator);
    call AppGlobalGet();
    GTxn(1,AssetReceiver); // TODO: Implement
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call GTxn(1,XferAsset); // TODO: Implement
    call Int(2);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call GTxn(1,AssetAmount); // TODO: Implement
    call Int(1);
    call Equal();
    if (IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0) {
      goto failed;
    }
    call Int(0);
    call Txn(ApplicationID);
    call Byte(voted);
    call AppGlobalGetEx(); // TODO: Implement
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
    call Int(GlobalRound);
    call Byte(regBegin);
    call AppGlobalGet();
    call GreatOrEqual();
    call Int(GlobalRound);
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
    call Int(1)
    call Return();
    return;
  failed:
    call Int(0);
    call Return();
  finished: 
    call Int(1);
    call Return();
  }

