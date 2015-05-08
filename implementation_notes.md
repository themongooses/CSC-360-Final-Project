Define procedures in .code sections. Loose code goes in the .run section. This is to seperate the procedure logic from the main logic tying them together. 

32 bit memory width, with an offset with of 8 bits. This makes reading the majority of data easy.

The point of this language is to make assembly easy to write and read

It has relative position branching. For example, when you encounter a JUMPTO or BRANCH command, the way the jump is calculated is with a program counter offset. This is easier to calculate for the majority of reasons you'd use a jump or branch (to a label). So when a branch or jump succeeds (jumps always succeed), take the current Program Counter, add the offset to it, then resume execution at the new Program Counter location

It has absolute procedure calling. For example, if upon assembly, procedure `FOO` is created and stored into memory at 0x6000, then an instruction `call FOO` will look like this: `001010 110000000000000`. When executing the instruction, the current Program Counter is saved on the stack, and the address of the procedure is written to the Program Counter. When the procedure is done, marked by the instruction RETURN (`010110`), then the old Program Counter value is popped off the stack back onto the Program Counter register. The program then resumes execution as normal.

The architecture has a 32 bit register design, except for the TF register, which is 8 bits. There are for General Purpose registers: GP1, GP2, GP3, and GP4. There are 4 registers used for passing procedure arguments: AR1, AR2, AR3, and AR4. This is similar to MIPS and is where inspiration was drawn from. In that same vein, there are 4 return value registers: RV1, RV2, RV3, and RV4. The AR and RV registers are just specially named 32 bit general purpose registers and can really be used for anything, but are there to make writing procedures somewhat uniform and predictable. There is also the 32 bit Stack Pointer (SP) register, which can be manipulated with the POP, POPVAL, and STACK operations. It can also be manipulated manually with offsets to arbitrarily shrink or grow the stack but this is not really recommended. 

The TF register is a register that holds the following bits: and, greater than, less than, equal, xor, xnor, sign, carry (still debating on these). This register is manipulated by the COMPARE* and BRANCH* instructions. It is reset every time a BRANCH or BRANCH_AND instruction is executed. The inspiration from this was originally an original thought, but further research shows that something similar is in the Itanium processor in the form of its 64 1-bit predicate registers (http://www.cs.virginia.edu/~gjp5j/itanium.pdf and http://www.cs.nmsu.edu/~rvinyard/itanium/predication.htm). It was actually made to run parallel code, so it does not take a performance hit doing complex comparisons because it runs them at the same time and chooses the correct code paths to keep. However, for our purposes (readable code) a performance hit is acceptable. Plus, we're not doing exactly what the Itanium is doing (parallel comparisons to decide parallel code paths).

The COMPARE* and BRANCH* operations are handled as such. If a general COMPARE instruction is given, then the CPU makes a comparison of A to B and sets all of the corresponding bits in the TF register. For example, `COMPARE 8,9` is saying "Compare 8 to 9", which will cause the TF register to set the bits representing less than to true. If another general COMPARE instruction is made, then the register is reset and the new values are calculated. Alternatively, if a specific comparison is made, then the TF register is not reset, and only the relevant comparison bits are modified. This allows chaining of comparisons. For example, the code `( plain >= 'a' && plain <= 'x')` can be compiled to:
```
compare_ge plain, 'a'
compare_le plain, 'x'
branch_and cond1_true
```
This is a CISC architecture. Full two-way access directly to memory