type Ref;
const unique zero: Ref;
var Alloc: [Ref] bool;
var Globals: [Ref] Ref;
var GlobalsAlloc: [Ref] bool;
var ScratchSpace: [int] Ref;
var ScratchSpaceAlloc: [int] bool;
var StackPointer: int;
var Stack: [int] Ref;
var IsInt: [Ref] bool;
var RefToInt: [Ref] int;



procedure FreshRefGenerator() returns (newRef: Ref);
  modifies Alloc;
  modifies IsInt;
  ensures old(Alloc[newRef] == false);
  ensures Alloc[newRef] == true;
  ensures newRef != zero;
  ensures IsInt[newRef] == false;
  ensures (forall ref: Ref :: ref != newRef ==> IsInt[ref] == old(IsInt[ref]));
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
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Push(value: Ref) {
  StackPointer := StackPointer + 1;
  Stack[StackPointer] := value;
  }

procedure Pop() returns (top: Ref);
  requires StackPointer >= 0;
  modifies StackPointer;
  ensures StackPointer == old(StackPointer) - 1;
  ensures top == old(Stack[old(StackPointer)]);
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures (forall j: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures (forall j: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Load(i: int) {
  call Push(ScratchSpace[i]);
  }

procedure AppGlobalGet();
  requires StackPointer >= 0;
  modifies Stack;
  modifies StackPointer;
  ensures (GlobalsAlloc[old(Stack[old(StackPointer)])] == true && Stack[StackPointer] == Globals[old(Stack[old(StackPointer)])]) || Stack[StackPointer] == zero;
  ensures StackPointer == old(StackPointer);
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)-1]) ==> Globals[ref] == old(Globals[ref]));
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
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
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
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> IsInt[ref] == old(IsInt[ref]));
implementation Int(n: int) {
  var value: Ref;
  call value := FreshRefGenerator();
  IsInt[value] := true;
  RefToInt[value] := n;
  call Push(value);
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
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Sum() {
  var aRef: Ref;
  var bRef: Ref;
  call aRef := Pop();
  call bRef := Pop();
  call Int(RefToInt[aRef] + RefToInt[bRef]);
  }

procedure Byte() returns (ref: Ref);
  modifies Stack;
  modifies StackPointer;
  modifies Alloc;
  modifies IsInt;
  ensures Stack[StackPointer] == ref;
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int:: -1 < i && i < StackPointer ==> Stack[i] == old(Stack[i]));
implementation Byte() returns (ref: Ref) {
  call ref := FreshRefGenerator();
  call Push(ref);
  }

procedure Return();
  requires !IsInt[Stack[StackPointer]] || RefToInt[Stack[StackPointer]] > 0;
implementation Return(){}

procedure contract();
  modifies Alloc;
  modifies ScratchSpace;
  modifies ScratchSpaceAlloc;
  modifies Stack;
  modifies StackPointer;
  modifies IsInt;
  modifies Globals;
  modifies GlobalsAlloc;
  modifies RefToInt;

// TODO RUN
// TODO ensure other stack elements stay the same
implementation contract() {
  var counter: Ref;
  StackPointer := -1;
  IsInt[zero] := true;
  RefToInt[zero] := 0;
  call counter := Byte();
  call Dup();
  call AppGlobalGet();
  call Int(1);
  assume(IsInt[Stack[StackPointer]] && IsInt[Stack[StackPointer-1]]);
  assume(RefToInt[Stack[StackPointer]] >= 0 && RefToInt[Stack[StackPointer-1]]>= 0);
  call Sum();
  call Dup();
  call Store(0);
  call AppGlobalPut();
  call Load(0);
  call Return();
  }

