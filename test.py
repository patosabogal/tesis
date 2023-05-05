import random
class Instruction:
    def __init__(self,name,inputs,has_output):
        self.name = name
        self.inputs = inputs * [None]
        self.has_output = has_output
        self.output_variable = Output(-1)
        self.unmatched_labels = []
        self.matched = 0
    def __str__(self):
        name_string = f"{self.name}"
        for input in self.inputs:
            name_string = f"{name_string} s{input.variable()}"
        name_input_string = name_string
        full_string = f""
        if not self.has_output:
            return name_input_string
        full_string += f"s{self.variable()} <- {name_input_string} \n"
        if len(self.unmatched_labels) > 0:
            variable_name = self.unmatched_labels.pop()
            full_string += f"s{variable_name} <- s{self.variable()} \n"
        return full_string
    def variable(self):
        return self.output_variable.variable()
class Jump(Instruction):
    def __init__(self,name,inputs, label):
        super().__init__(name,inputs,False)
        self.label = label


    def __str__(self):
        name_string = f"{self.name} ("
        for input in self.inputs:
            name_string = f"{name_string} s{input.variable()}"
        name_string += " )"
        return f"{name_string} {self.label}\n"

class Label(Instruction):
    def __init__(self,name) :
        super().__init__(name,0,False)

    def __str__(self):
        return f"{self.name}:\n"

class Output:
    def __init__(self, variable) -> None:
        self._variable = variable

    def variable(self):
        return self._variable


#teal = [Instruction("int 1", 0, 2), Instruction("add 1", 1,1), Instruction("int 1",0,1), Instruction("int 1",0,1), Instruction("and",2,1), Instruction("and",2,1), Instruction("return",1,0)]
teal = [
        Instruction("int 1", 0,1),
        Instruction("int 1", 0,1),
        Instruction("int 1",0,1),
        Instruction("int 1",0,1),
        Instruction("and",2,1),
        Instruction("and",2,1),
        Jump("jumpnz",1, "label"),
        Instruction("int 1",0, 1),
        Label("label"),
        Instruction("int 1",0, 1),
        Instruction("and",2,1),
        Instruction("return",1,0)
        ]
# que onda con los multiples push en el stack? Por ahi puede dividir a la funcion en 2
# al final fui por esto :flechita_arriba:
# TODO: splitteaer funciones con mas de un push
# TODO: chequear que onda al final con los POPS()
unmatched_instructions_stack = []
unmatched_labels_variables = {} # Push all unmatched instruccions and match them with a special variable name (i.e. not stack pointer but a random UNIQUE VALUE)
unmatched_labels_stack = [] # Append variables when encountering a jump.
current_stack_pointer = 0
teal.reverse()
for instruction in teal:
    if isinstance(instruction, Label):
        unmatched_labels_variables[instruction.name] = []
        for _ in range(len(unmatched_instructions_stack)):
            unmatched_instruction = unmatched_instructions_stack.pop(0)
            for j in range(unmatched_instruction.matched, len(unmatched_instruction.inputs)):
                variable_name = random.randint(1200,2400000000000000)
                unmatched_instruction.inputs[j] = Output(variable_name)
                unmatched_instruction.matched += 1
                unmatched_labels_variables[instruction.name].append(variable_name)
        unmatched_labels_stack.append(unmatched_labels_variables[instruction.name].copy())
    else:
      previous = len(unmatched_instructions_stack)
      if isinstance(instruction, Jump) and len(unmatched_labels_variables[instruction.label]) > 0:
        unmatched_labels_stack.append(unmatched_labels_variables[instruction.label].copy())
      if instruction.has_output:
        if len(unmatched_instructions_stack) > 0:
              last_unmatched_instruction = unmatched_instructions_stack[len(unmatched_instructions_stack)-1]
              last_unmatched_instruction.inputs[last_unmatched_instruction.matched] = instruction
              last_unmatched_instruction.matched += 1
              if last_unmatched_instruction.matched == len(last_unmatched_instruction.inputs):
                unmatched_instructions_stack.pop()
                if len(unmatched_instructions_stack) > 0:
                    last_unmatched_instruction = unmatched_instructions_stack[len(unmatched_instructions_stack)-1]
        instruction.output_variable = Output(current_stack_pointer);
        current_stack_pointer += 1
        if len(unmatched_instructions_stack) == 0 and previous == 0 and len(unmatched_labels_stack) > 0:
          for index, unmatched_label in enumerate(unmatched_labels_stack):
              variable_name = unmatched_label.pop(0)
              instruction.unmatched_labels.append(variable_name)
              if len(unmatched_label) == 0:
                  unmatched_labels_stack.pop(index)
      if len(instruction.inputs) > 0:
        current_stack_pointer = 0
        unmatched_instructions_stack.append(instruction)

teal.reverse()
for instr in teal:
    print(instr)

