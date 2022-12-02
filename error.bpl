type Ref;

type Field _;

const unique zero: Ref;

const unique OptIn: int;

const unique Noop: int;

const unique CloseOut: int;

var Alloc: [Ref]bool;

var Globals: [Ref]Ref;

var GlobalsAlloc: [Ref]bool;

var ScratchSpace: [int]Ref;

var ScratchSpaceAlloc: [int]bool;

var StackPointer: int;

var Stack: [int]Ref;

var IsInt: [Ref]bool;

var RefToInt: [Ref]int;

var CurrentTxn: Ref;

var Sender: [Ref]Ref;

var NumAppArgs: [Ref]Ref;

var ApplicationArgs: [Ref][int]Ref;

var OnCompletion: [Ref]Ref;

var Accounts: [Ref][int]Ref;

var GroupTransaction: [Ref][int]Ref;

var ApplicationID: [Ref]Ref;

var TypeEnum: [Ref]Ref;

var AssetReceiver: [Ref]Ref;

var XferAsset: [Ref]Ref;

var AssetAmount: [Ref]Ref;

procedure FreshRefGenerator() returns (newRef: Ref);
  modifies Alloc, IsInt;
  ensures old(Alloc[newRef] <==> false);
  ensures Alloc[newRef] <==> true;
  ensures newRef != zero;
  ensures IsInt[newRef] <==> false;
  ensures (forall ref: Ref :: ref != newRef ==> (IsInt[ref] <==> old(IsInt[ref])));
  ensures (forall ref: Ref :: ref != newRef ==> (Alloc[ref] <==> old(Alloc[ref])));



implementation FreshRefGenerator() returns (newRef: Ref)
{

  anon0:
    havoc newRef;
    assume Alloc[newRef] <==> false;
    Alloc[newRef] := true;
    IsInt[newRef] := false;
    assume newRef != zero;
    return;
}



procedure Push(value: Ref);
  modifies StackPointer, Stack;
  ensures old(StackPointer) + 1 == StackPointer;
  ensures Stack[StackPointer] == value;
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));



implementation Push(value: Ref)
{

  anon0:
    StackPointer := StackPointer + 1;
    Stack[StackPointer] := value;
    return;
}



procedure Pop() returns (top: Ref);
  requires StackPointer >= 0;
  modifies StackPointer;
  ensures StackPointer == old(StackPointer) - 1;
  ensures top == old(Stack[old(StackPointer)]);



implementation Pop() returns (top: Ref)
{

  anon0:
    top := Stack[StackPointer];
    StackPointer := StackPointer - 1;
    return;
}



procedure Store(i: int);
  requires 0 <= i;
  requires i < 64;
  requires StackPointer >= 0;
  modifies ScratchSpace, ScratchSpaceAlloc, Stack, StackPointer;
  ensures ScratchSpaceAlloc[i] <==> true;
  ensures ScratchSpace[i] == Stack[old(StackPointer)];
  ensures StackPointer == old(StackPointer) - 1;
  ensures (forall j: int :: -1 <= j && j <= StackPointer ==> Stack[j] == old(Stack[j]));
  ensures (forall j: int :: 0 < j && j < 64 && i != j ==> ScratchSpace[j] == old(ScratchSpace[j]));
  ensures (forall j: int :: 0 < j && j < 64 && i != j ==> (ScratchSpaceAlloc[j] <==> old(ScratchSpaceAlloc[j])));



procedure Load(i: int);
  requires 0 <= i;
  requires i < 64;
  requires ScratchSpaceAlloc[i] <==> true;
  modifies Stack, StackPointer;
  ensures Stack[StackPointer] == ScratchSpace[i];
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall j: int :: -1 <= j && j < StackPointer ==> Stack[j] == old(Stack[j]));
  ensures (forall j: int :: 0 < j && j < 64 && i != j ==> (ScratchSpaceAlloc[j] <==> old(ScratchSpaceAlloc[j])));



procedure AppGlobalGet();
  requires StackPointer >= 0;
  modifies Stack, StackPointer;
  ensures ((GlobalsAlloc[old(Stack)[old(StackPointer)]] <==> true) && Stack[StackPointer] == Globals[old(Stack)[old(StackPointer)]]) || Stack[StackPointer] == zero;
  ensures StackPointer == old(StackPointer);
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));



procedure AppGlobalPut();
  requires StackPointer > 0;
  modifies StackPointer, GlobalsAlloc, Globals;
  ensures GlobalsAlloc[old(Stack[old(StackPointer) - 1])] <==> true;
  ensures Globals[old(Stack[old(StackPointer) - 1])] == old(Stack[old(StackPointer)]);
  ensures StackPointer == old(StackPointer) - 2;
  ensures (forall i: int :: -1 <= i && i <= StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer) - 1]) ==> Globals[ref] == old(Globals[ref]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer) - 1]) ==> (GlobalsAlloc[ref] <==> old(GlobalsAlloc[ref])));



implementation AppGlobalPut()
{
  var value: Ref;
  var key: Ref;

  anon0:
    call {:si_unique_call 0} value := Pop();
    call {:si_unique_call 1} key := Pop();
    GlobalsAlloc[key] := true;
    Globals[key] := value;
    return;
}



procedure Dup();
  requires StackPointer >= 0;
  modifies Stack, StackPointer;
  ensures Stack[old(StackPointer)] == old(Stack[old(StackPointer)]);
  ensures Stack[StackPointer] == old(Stack[old(StackPointer)]);
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));



procedure Int(n: int);
  requires n >= 0;
  modifies Alloc, IsInt, RefToInt, StackPointer, Stack;
  ensures IsInt[Stack[StackPointer]];
  ensures RefToInt[Stack[StackPointer]] == n;
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> (IsInt[ref] <==> old(IsInt[ref])));
  ensures (forall ref: Ref :: ref != Stack[StackPointer] ==> (Alloc[ref] <==> old(Alloc[ref])));



implementation Int(n: int)
{
  var newRef: Ref;

  anon0:
    call {:si_unique_call 2} newRef := FreshRefGenerator();
    IsInt[newRef] := true;
    RefToInt[newRef] := n;
    call {:si_unique_call 3} Push(newRef);
    return;
}



procedure Sum();
  requires StackPointer > 0;
  requires IsInt[Stack[StackPointer]];
  requires IsInt[Stack[StackPointer - 1]];
  requires RefToInt[Stack[StackPointer]] >= 0;
  requires RefToInt[Stack[StackPointer - 1]] >= 0;
  modifies IsInt, Alloc, StackPointer, Stack, RefToInt;
  ensures RefToInt[Stack[StackPointer]] == old(RefToInt[old(Stack[old(StackPointer)])]) + old(RefToInt[old(Stack[old(StackPointer) - 1])]);
  ensures StackPointer == old(StackPointer) - 1;
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer) - 1]) && ref != Stack[StackPointer] ==> RefToInt[ref] == old(RefToInt[ref]));
  ensures (forall ref: Ref :: ref != old(Stack[old(StackPointer)]) && ref != old(Stack[old(StackPointer) - 1]) && ref != Stack[StackPointer] ==> (IsInt[ref] <==> old(IsInt[ref])));



procedure Byte(ref: Ref);
  requires ref != zero;
  requires IsInt[ref] <==> false;
  modifies StackPointer, Stack;
  ensures IsInt[ref] <==> false;
  ensures Stack[StackPointer] == ref;
  ensures StackPointer == old(StackPointer) + 1;
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));
  ensures (forall ref': Ref :: ref != ref' ==> (IsInt[ref'] <==> old(IsInt[ref'])));
  ensures (forall ref': Ref :: ref != ref' ==> (Alloc[ref'] <==> old(Alloc[ref'])));



implementation Byte(ref: Ref)
{

  anon0:
    call {:si_unique_call 4} Push(ref);
    return;
}



procedure Return();
  requires !IsInt[Stack[StackPointer]] || RefToInt[Stack[StackPointer]] > 0;



implementation Return()
{

  anon0:
    return;
}



procedure Txn(field: [Ref]Ref);
  modifies StackPointer, Stack;
  ensures StackPointer == old(StackPointer) + 1;
  ensures Stack[StackPointer] == field[CurrentTxn];
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));



implementation Txn(field: [Ref]Ref)
{

  anon0:
    call {:si_unique_call 5} Push(field[CurrentTxn]);
    return;
}



procedure Equal();
  requires StackPointer > 0;
  requires Stack[StackPointer] == zero || Stack[StackPointer - 1] == zero || (IsInt[Stack[StackPointer]] <==> IsInt[Stack[StackPointer - 1]]);
  modifies StackPointer, Alloc, IsInt, RefToInt, Stack;
  ensures StackPointer == old(StackPointer - 1);
  ensures IsInt[Stack[StackPointer]];
  ensures RefToInt[Stack[StackPointer]] == 1 || RefToInt[Stack[StackPointer]] == 0;
  ensures old(Stack[StackPointer]) == old(Stack[StackPointer - 1]) ==> RefToInt[Stack[StackPointer]] == 1;
  ensures old(IsInt[Stack[StackPointer]]) && old(IsInt[Stack[StackPointer - 1]]) && old(RefToInt[Stack[StackPointer]]) == old(RefToInt[Stack[StackPointer - 1]]) ==> RefToInt[Stack[StackPointer]] == 1;
  ensures (forall ref': Ref :: Stack[StackPointer] != ref' ==> (IsInt[ref'] <==> old(IsInt[ref'])));
  ensures (forall ref': Ref :: Stack[StackPointer] != ref' ==> RefToInt[ref'] == old(RefToInt[ref']));
  ensures (forall ref': Ref :: Stack[StackPointer] != ref' ==> (Alloc[ref'] <==> old(Alloc[ref'])));
  ensures (forall i: int :: -1 <= i && i < StackPointer ==> Stack[i] == old(Stack[i]));



implementation Equal()
{
  var aRef: Ref;
  var bRef: Ref;

  anon0:
    call {:si_unique_call 6} aRef := Pop();
    call {:si_unique_call 7} bRef := Pop();
    goto anon3_Then, anon3_Else;

  anon3_Then:
    assume {:partition} aRef == bRef || (IsInt[aRef] && RefToInt[aRef] == RefToInt[bRef]);
    call {:si_unique_call 8} Int(1);
    return;

  anon3_Else:
    assume {:partition} !(aRef == bRef || (IsInt[aRef] && RefToInt[aRef] == RefToInt[bRef]));
    goto anon2;

  anon2:
    call {:si_unique_call 9} Int(0);
    return;
}



procedure contract();
  requires StackPointer == -1;
  requires (forall ref: Ref :: IsInt[ref] <==> false);
  requires (forall ref: Ref :: GlobalsAlloc[ref] <==> false);
  requires (forall ref: Ref :: Alloc[ref] <==> false);
  requires (forall i: int :: ScratchSpaceAlloc[i] <==> false);
  requires (forall i: int :: Stack[i] == zero);
  modifies IsInt, RefToInt, ApplicationID, Alloc, StackPointer, Stack, GlobalsAlloc, Globals;



implementation contract()
{
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

  anon0:
    IsInt[zero] := true;
    RefToInt[zero] := 0;
    ApplicationID[CurrentTxn] := zero;
    call {:si_unique_call 10} creator := FreshRefGenerator();
    call {:si_unique_call 11} regBegin := FreshRefGenerator();
    call {:si_unique_call 12} regEnd := FreshRefGenerator();
    call {:si_unique_call 13} voteBegin := FreshRefGenerator();
    call {:si_unique_call 14} voteEnd := FreshRefGenerator();
    call {:si_unique_call 15} register := FreshRefGenerator();
    call {:si_unique_call 16} vote := FreshRefGenerator();
    call {:si_unique_call 17} voted := FreshRefGenerator();
    call {:si_unique_call 18} candidatea := FreshRefGenerator();
    call {:si_unique_call 19} candidateb := FreshRefGenerator();
    assert Stack[StackPointer] != creator;
    call {:si_unique_call 20} Int(0);
    assert Stack[StackPointer] != creator;
    call {:si_unique_call 21} Txn(ApplicationID);
    call {:si_unique_call 22} Equal();
    goto anon4_Then, anon4_Else;

  anon4_Then:
    assume {:partition} IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0;
    goto failed;

  anon4_Else:
    assume {:partition} !(IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0);
    goto anon2;

  anon2:
    call {:si_unique_call 23} Byte(creator);
    call {:si_unique_call 24} Txn(Sender);
    call {:si_unique_call 25} AppGlobalPut();
    assume IsInt[NumAppArgs] <==> true;
    assume RefToInt[NumAppArgs] == 4;
    call {:si_unique_call 26} Txn(NumAppArgs);
    call {:si_unique_call 27} Int(4);
    call {:si_unique_call 28} Equal();
    goto anon5_Then, anon5_Else;

  anon5_Then:
    assume {:partition} IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0;
    goto failed;

  anon5_Else:
    assume {:partition} !(IsInt[Stack[StackPointer]] && RefToInt[Stack[StackPointer]] == 0);
    goto failed;

  failed:
    call {:si_unique_call 29} Int(0);
    call {:si_unique_call 30} Return();
    goto finished;

  finished:
    call {:si_unique_call 31} Int(1);
    call {:si_unique_call 32} Return();
    return;
}


