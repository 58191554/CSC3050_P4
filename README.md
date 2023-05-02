# CSC3050_P4
Pipeline CPU by verilog
5-stage MIPS Pipeline CPU Description
Different from single-cycle CPUS, multi-cycle CPU divide the entire CPU execution process into 5stages. Each stage is completed
with a clock, and then the next instruction is executed.
When the CPU processes instructions, it generally goes through the following stages:
1. Fetch instruction (IF): The Program Counter gets the instruction from an Instruction RAM. At the same time, PC automatically
increases a word to generate an instruction address for the next instruction. But when encountering branch or jump instruction,
the controller "transfer address" into the PC
2. Instruction decoding (ID): Decode the instructions obtained in the instruction.
3. Instruction execution (EXE): According to the operation control signal obtained by instruction decoding, the specific thing of
the instruction is executed, and then transferred the result back.
4. Memory access (MEM): All operations that need to access memory will be performed in this step.
5. Write back (WB): The result of instruction execution or data obtained from accessing memory is written back to the
corresponding destination register.

