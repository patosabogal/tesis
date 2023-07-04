var on_complete_0 : int;
var arguments_0_0 : int;
var arguments_0_1 : int;
var arguments_0_2 : int;
var accounts_0_0 : int;
var applications_0_0 : int;
var choice : int;
var return_variable : int;
var Global : [int] int;
var Local : [int] [int] int;

function to_int(x: bool) returns (int);
axiom to_int(false) == 0;
axiom to_int(true) == 1;

procedure add_();
implementation add_(){
arguments_0_0 := 5675630968779434188477772362910438625249015836853771597901718535855005190167;
havoc arguments_0_1;
havoc arguments_0_2;
on_complete_0 := 0;
call contract_();
}

procedure sub_();
implementation sub_(){
arguments_0_0 := 97683292221467415895849119049791858608323619716901355206417505369266074403911;
havoc arguments_0_1;
havoc arguments_0_2;
on_complete_0 := 0;
call contract_();
}

procedure div_();
implementation div_(){
arguments_0_0 := 81780703314405585889233239203870720927139862378435693135684859115222397344564;
havoc arguments_0_1;
havoc arguments_0_2;
on_complete_0 := 0;
call contract_();
}

procedure mul_();
implementation mul_(){
arguments_0_0 := 54234213662080840067953318094965119764394243260767325613599977702755392238155;
havoc arguments_0_1;
havoc arguments_0_2;
on_complete_0 := 0;
call contract_();
}

procedure add_n_();
implementation add_n_(){
arguments_0_0 := 54618277432654078345054807582972379234579797765171563559473905395813683669417;
havoc arguments_0_1;
on_complete_0 := 0;
call contract_();
}

procedure verify_();
implementation verify_(){
call add_();
while (true){
havoc choice;
if ((choice) == 0) {
call add_();
}
if ((choice) == 1) {
call sub_();
}
if ((choice) == 2) {
call div_();
}
if ((choice) == 3) {
call mul_();
}
if ((choice) == 4) {
call add_n_();
}
}
}

procedure contract_();
implementation contract_(){
var scratch_0 : int;
var scratch_1 : int;
var scratch_2 : int;
var scratch_3 : int;
var scratch_4 : int;
var scratch_5 : int;
var scratch_6 : int;
var scratch_7 : int;
var scratch_8 : int;
var scratch_9 : int;
var scratch_10 : int;
var scratch_11 : int;
var scratch_12 : int;
var scratch_13 : int;
var scratch_14 : int;
var scratch_15 : int;
var scratch_16 : int;
var scratch_17 : int;
var scratch_18 : int;
var scratch_19 : int;
var scratch_20 : int;
var scratch_21 : int;
var scratch_22 : int;
var scratch_23 : int;
var scratch_24 : int;
var scratch_25 : int;
var scratch_26 : int;
var scratch_27 : int;
var scratch_28 : int;
var scratch_29 : int;
var scratch_30 : int;
var scratch_31 : int;
var scratch_32 : int;
var scratch_33 : int;
var scratch_34 : int;
var scratch_35 : int;
var scratch_36 : int;
var scratch_37 : int;
var scratch_38 : int;
var scratch_39 : int;
var scratch_40 : int;
var scratch_41 : int;
var scratch_42 : int;
var scratch_43 : int;
var scratch_44 : int;
var scratch_45 : int;
var scratch_46 : int;
var scratch_47 : int;
var scratch_48 : int;
var scratch_49 : int;
var scratch_50 : int;
var scratch_51 : int;
var scratch_52 : int;
var scratch_53 : int;
var scratch_54 : int;
var scratch_55 : int;
var scratch_56 : int;
var scratch_57 : int;
var scratch_58 : int;
var scratch_59 : int;
var scratch_60 : int;
var scratch_61 : int;
var scratch_62 : int;
var scratch_63 : int;
var phi_value_3_0 : int;
var local_2 : int;
var phi_value_1_0 : int;
var phi_2_0 : int;
var local_0 : int;
var phi_1_0 : int;
var phi_3_0 : int;
var phi_value_2_1 : int;
var local_1 : int;
var phi_2_1 : int;
var local_3 : int;
var phi_value_2_0 : int;
label_0:
local_0 := 1;
phi_value_1_0 := local_0;
phi_value_3_0 := local_0;
local_1 := 2;
local_2 := 9;
local_3 := to_int(local_2 < local_1);
if(local_3 == 0) {
    goto label_3;
}
else {
    goto label_1;
}
label_1:
phi_1_0 := phi_value_1_0;
phi_value_2_0 := phi_1_0;
local_0 := 6;
phi_value_2_1 := local_0;
goto label_2;
label_2:
phi_2_0 := phi_value_2_0;
phi_2_1 := phi_value_2_1;
local_0 := phi_2_1 + phi_2_0;
return_variable := local_0;
goto label_exit;
label_3:
phi_3_0 := phi_value_3_0;
phi_value_2_0 := phi_3_0;
local_0 := 5675630968779434188477772362910438625249015836853771597901718535855005190167;
phi_value_2_1 := local_0;
goto label_2;
label_exit:
return;
}

