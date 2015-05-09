The point of this language is to make assembly easy to write and read. Inspiration is taken from MIPS and its simplicity, which is why it's used to teach computer architecture

Define procedures in `.code` sections. Loose code goes in the `.run` section. This is to seperate the procedure logic from the main logic tying them together. When the program is executed, execution starts on the first line after `.run` and continues until there are no more instructions to execute (the compiler automatically inserts a return at the end)

32 bit memory width, with an offset width of 8 bits. This makes reading the majority of data easy. This means that for every 1 offset, 8 bits are offset for the current value.

It has relative position branching. For example, when you encounter a `JUMPTO` or `BRANCH` command, the way the jump is calculated is with a program counter offset. This is easier to calculate for the majority of reasons you'd use a jump or branch (to a label). So when a branch or jump succeeds (jumps always succeed), take the current Program Counter, add the offset to it, then resume execution at the new Program Counter location

It has absolute procedure calling. For example, if upon assembly, procedure `FOO` is created and stored into memory at 0x6000, then an instruction `call FOO` will look like this: `001010 00000000000000000110000000000000`. When executing the instruction, the current Program Counter is saved on the stack, and the address of the procedure is written to the Program Counter. When the procedure is done, marked by the instruction `RETURN` (`010110`), then the old Program Counter value is popped off the stack back onto the Program Counter register. The program then resumes execution as normal.

List/Explaination of Registers
==============================
The architecture has a 32 bit register design, except for the TF register, which is 8 bits. There are for General Purpose registers: GP1, GP2, GP3, and GP4. There are 4 registers used for passing procedure arguments: AR1, AR2, AR3, and AR4. This is similar to MIPS and is where inspiration was drawn from. In that same vein, there are 4 return value registers: RV1, RV2, RV3, and RV4. The AR and RV registers are just specially named 32 bit general purpose registers and can really be used for anything, but are there to make writing procedures somewhat uniform and predictable. There is also the 32 bit Stack Pointer (SP) register, which can be manipulated with the `POP`, `POPVAL`, and `STACK` operations. It can also be manipulated manually with offsets to arbitrarily shrink or grow the stack but this is not really recommended. 

The TF register is a register that holds the following bits: and, greater than, less than, equal, xor, xnor, sign, carry (still debating on these). This register is manipulated by the `COMPARE*` and `BRANCH*` instructions. It is reset every time a `BRANCH` or `BRANCH_AND` instruction is executed. The inspiration from this was originally an original thought, but further research shows that something similar is in the Itanium processor in the form of its 64 1-bit predicate registers (http://www.cs.virginia.edu/~gjp5j/itanium.pdf and http://www.cs.nmsu.edu/~rvinyard/itanium/predication.htm). It was actually made to run parallel code, so it does not take a performance hit doing complex comparisons because it runs them at the same time and chooses the correct code paths to keep. However, for our purposes (readable code) a performance hit is acceptable. Plus, we're not doing exactly what the Itanium is doing (parallel comparisons to decide parallel code paths).

The `COMPARE*` and `BRANCH*` operations are handled as such. If a general `COMPARE` instruction is given, then the CPU makes a comparison of A to B and sets all of the corresponding bits in the TF register. For example, `COMPARE 8,9` is saying "Compare 8 to 9", which will cause the TF register to set the bits representing less than to true. If another general `COMPARE` instruction is made, then the register is reset and the new values are calculated. Alternatively, if a specific comparison is made, then the TF register is not reset, and only the relevant comparison bits are modified. This allows chaining of comparisons. For example, the code `( plain >= 'a' && plain <= 'x')` can be compiled to:
```
compare_ge plain, 'a'
compare_le plain, 'x'
branch_and cond1_true
```

There are two `BRANCH*` operations, `BRANCH` and `BRANCH_AND`. `BRANCH` is successful only if the TF register is not 0. `BRANCH_AND` is successful only if the `and` bit is set in TF, which is only true if more than one back-to-back specific comparisons are made. TF is reset after a `BRANCH*` method is executed.

This is a CISC architecture. Full two-way access directly to memory. This means that it is possible to read directly from memory and write directly back to memory in a single instruction. To simplify instruction parsing and coding, each opcode has its own structure, though they may follow a general pattern. For example, there are two versions of `ADD`: `ADD` and `ADD2`. `ADD` takes two arguments, with the only restriction being that the first MUST be a writeable location (memory or register). Alternatively, `ADD2` takes in 3 arguments, with the restriction that the third argument MUST be a writeable location.

Addressing Modes (List and explainations)
=========================================
Memory is accessed directly by typing the register or the memory variable. To get the offset of a variable, use brackets [] around it. For example, if `foo` is a 32 bit DWORD stored at `0x3000h` with a value of `7657`, then `move GP1, foo` will update `GP1` with the value of `7657`. Conversely, if one were to write `move GP1, [foo]`, then `GP1` would update with the value of `0x3000h`, the memory address of `foo`. One can also access the offset of a variable using array index notation like that found in languages such as Java: `foo[x]`. This will refer to the address at the memory base of `foo` plus the 8 bit offset multiple of `x`. So, if `foo` were to again have the address of `0x3000h`, then `foo[3]` would refer to the memory address `0x3003h`. You may not chain an index and an offset, i.e: `[foo[x]]`.

Immediate values are limited to 8 bits to cut down on program size.

Instructions
--------------
Coding Scheme
============================
Because of the CPU being a full CISC operation and having "two-way" direct memory access, it is possible to read and write directly to memory in a single instruction. To simplify instruction parsing and coding, each opcode has its own structure, though they may follow a general pattern. For example, there are two versions of `ADD`: `ADD` and `ADD2`. `ADD` takes two arguments, with the only restriction being that the first MUST be a writeable location (memory or register). Alternatively, `ADD2` takes in 3 arguments, with the restriction that the third argument MUST be a writeable location. In the example of `ADD2`, there may be a maximum width of 6+3+32+3+32+3+32=111 bits for an instruction, assuming that all three arguments are direct memory locations. In essence though, the CPU will do a lookup of what the instruction widths will be at run time based on the instruction table. However, a general instruction has the following structure:

| Operation | Address Mode |     Value     | Address Mode (Optional) | Value (Optional) | Address Mode (Optional) | Value (Optional) |
|:---------:|:------------:|:-------------:|:-----------------------:|:----------------:|:-----------------------:|:----------------:|
|   6 bits  |    3 bits    | Up to 32 bits |          3 bits         |   Up to 32 bits  |          3 bits         |   Up to 32 bits  |

The above structure holds true for many of the codes, such as the arithmetic operations, where the extended versions (potentially) use all 111 bits. It will pad out the right hand side to 128 bits, for 4 DWORD byte instruction width total. For smaller instructions such as the `RETURN` code, only 6 bits will be used. The rest will be padded out with zeroes to fit 32 bits.In general, the instruction will be encoded to pad the right hand side of the instruction with zeroes to fill up to the next DWORD multiple size. This makes our programs fit within 32 bit allotments in memory and play nicely with the 32 bit Program Counter.

| Operation (6 bits) |              Address Mode             |     Value     | Address Mode (Optional) | Value (Optional) | Address Mode (Optional) | Value (Optional) |                    Width                    |
|:------------------:|:-------------------------------------:|:-------------:|:-----------------------:|:----------------:|:-----------------------:|:----------------:|:-------------------------------------------:|
|       6 bits       |                 3 bits                | Up to 32 bits |          3 bits         |   Up to 32 bits  |          3 bits         |   Up to 32 bits  | Round up to the nearest DWORD byte multiple |
|         ADD        |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|        ADD2        |              Address Mode             |     Value     |       Address Mode      |       Value      |       Address Mode      |       Value      |                   128 Bits                  |
|      SUBTRACT      |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|      SUBTRACT2     |              Address Mode             |     Value     |       Address Mode      |       Value      |       Address Mode      |       Value      |                   128 Bits                  |
|      MULTIPLY      |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 Bits                   |
|      MULTIPLY2     |              Address Mode             |     Value     |       Address Mode      |       Value      |       Address Mode      |       Value      |                   128 Bits                  |
|       DIVIDE       |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 Bits                   |
|       DIVIDE2      |              Address Mode             |     Value     |       Address Mode      |       Value      |       Address Mode      |       Value      |                   128 Bits                  |
|        MOVE        |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|       JUMPTO       | 32 bit address to location to jump to |       -       |            -            |         -        |            -            |         -        |                   64 bits                   |
|        CALL        |      32 bit address to procedure      |       -       |            -            |         -        |            -            |         -        |                   64 bits                   |
|        STACK       |              Address Mode             |     Value     |            -            |         -        |            -            |         -        |                   64 bits                   |
|       RETURN       |                   -                   |       -       |            -            |         -        |            -            |         -        |                   32 bits                   |
|         POP        |              Address Mode             |     Value     |            -            |         -        |            -            |         -        |                   64 bits                   |
|       POPVAL       |              Address Mode             |     Value     |            -            |         -        |            -            |         -        |                   64 bits                   |
|       COMPARE      |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     COMPARE_GT     |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     COMPARE_LT     |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     COMPARE_GE     |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     COMPARE_LE     |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     COMPARE_EQ     |              Address Mode             |     Value     |       Address Mode      |       Value      |            -            |         -        |                   96 bits                   |
|     BRANCH_AND     | 32 bit address to location to jump to |       -       |            -            |         -        |            -            |         -        |                   64 bits                   |
|       BRANCH       | 32 bit address to location to jump to |       -       |            -            |         -        |            -            |         -        |                   64 bits                   |
|                    |                                       |               |                         |                  |                         |                  |                                             |
|                    |                                       |               |                         |                  |                         |                  |                                             |