import json
from typing import List, TypedDict


class InstructionDict(TypedDict):
    op: str
    args: List[str]
    consumes: List[int]


class BasicBlockDict(TypedDict):
    incoming_edges: List[int]
    outgoing_edges: List[int]
    phis: List[List[int]]
    instructions: List[InstructionDict]
    terminal: InstructionDict


class TealiftDict(TypedDict):
    entrypoint: int
    basic_blocks: List[BasicBlockDict]


class Instruction:
    def __init__(
        self, operation: str, arguments: List[str] = [], consumes: List[int] = []
    ):
        self.operation = operation
        self.arguments = arguments or []
        self.consumes = consumes or []

    @classmethod
    def from_json(cls, json_string: str):
        loaded_json = json.load(json_string)
        return cls.from_dict(loaded_json)

    @classmethod
    def from_dict(cls, instruction_dict: InstructionDict):
        return cls(
            instruction_dict["op"],
            instruction_dict["args"],
            instruction_dict["consumes"],
        )


class BasicBlock:
    def __init__(
        self,
        incoming_edges: List[int],
        outgoing_edges: List[int],
        phis: List[List[int]],
        instructions: List[Instruction],
        terminal: Instruction,
    ):
        self.incoming_edges = incoming_edges or []
        self.outgoing_edges = outgoing_edges or []
        self.phis = phis or []
        self.instructions = instructions or []
        self.terminal = terminal
        self.instructions.append(self.terminal)

    @classmethod
    def from_json(cls, json_string: str):
        loaded_json = json.load(json_string)
        return cls.from_dict(loaded_json)

    @classmethod
    def from_dict(cls, dictionary: BasicBlockDict):
        instructions = map(
            lambda instruction: Instruction.from_dict(instruction),
            dictionary["instructions"],
        )
        return cls(
            dictionary["incoming_edges"],
            dictionary["outgoing_edges"],
            dictionary["phis"],
            list(instructions),
            Instruction.from_dict(dictionary["terminal"]),
        )


class Tealift:
    def __init__(self, entrypoint_index: int, basic_blocks: List[BasicBlock]):
        self.entrypoint_index = entrypoint_index
        self.basic_blocks = basic_blocks

    @classmethod
    def from_json(cls, json_string: str):
        loaded_json = json.loads(json_string)
        return cls.from_dict(loaded_json)

    @classmethod
    def from_dict(cls, dictionary: TealiftDict):
        basic_blocks = map(
            lambda bb: BasicBlock.from_dict(bb), dictionary["basic_blocks"]
        )
        return cls(dictionary["entrypoint"], list(basic_blocks))

    def _get_phi_instructions(self, block_index: int, phi_values: List[int]):
        res = []
        incoming_edges = self.basic_blocks[block_index].incoming_edges
        for incoming_edges_index, incoming_edge in enumerate(incoming_edges):
            if phi_values[incoming_edges_index] >= 0:
                res.extend([(incoming_edge, phi_values[incoming_edges_index])])
            else:
                res.extend(
                    self._get_phi_instructions(
                        incoming_edge,
                        self.basic_blocks[incoming_edge].phis[
                            abs(phi_values[incoming_edges_index]) - 1
                        ],
                    )
                )
        return res

    def phis_values(self):
        phis_dict = {}
        for basic_block_index, basic_block in enumerate(self.basic_blocks):
            for phi_index, phi in enumerate(basic_block.phis):
                for incoming_edges_index, incoming_edge in enumerate(
                    basic_block.incoming_edges
                ):
                    # Get values already processed.
                    values = phis_dict.get(
                        (incoming_edge, phi[incoming_edges_index]), []
                    )
                    # Append new value
                    values.append((basic_block_index, phi_index))
                    phis_dict[(incoming_edge, phi[incoming_edges_index])] = values
        return phis_dict

    @property
    def instructions(self):
        instructions = []
        for basic_block in self.basic_blocks:
            instructions.extend(tuple(basic_block.instructions))
        return list(instructions)
