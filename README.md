# MALI - marwins assembly language interpreter

this is a made up assembly langauge and an interpreter for it.
i want to compile my programming langauge to it, but this is significantly simpler then real assembly.
also i want to learn stuff about stack machines.
however this is somewhat inspired by real assembly.


## instructions & syntax

### syntax

its always 
```
INSTR arg arg ...
```
where arg can be one of the following things: `$stackname`, `%memorypointername`, an integer or an float.

### special stuff
there is a stack of 'instruction pointers' called $ips.\
you can access it directly, but it is mainly used for the 'CALL' and 'RET' instructions. if you mess with it, it might get real complicated. it will just contain integer numbers, which are the number of the instruction to execute next. this number is the order in the parsed list of instructions and does not represent any line number in the file.

### instructions
as notation '$' represents any stack name, '%' any pointer name 'i' any int and 'f' any float.\
the only other thing that exists is the label. which is just plain text and will be denoted as 'label' in the following.\
labels are somewhat special as they are just a makro which will be replaced in the preprocessor by an instruction pointer.\
if something accepts more then one option this will be written as '(i,f,%,$)' for example.

these are all instructions i implemented

// ALLOC FREE LOAD LOADH LOADL STORE STOREH REML REMH LABEL CALL GOTO JMP0 JMP1 RET EXIT OUT PUSH CPY MOV POP EQ EQV ADD SUB MUL DIV MOD AND OR

ALLOC % - allocate memory (mutable list) at %\
FREE % - deallocates the memory at %\
LOAD % i $ - loads i'th element of mempointer to head of stack\
LOADH % $ - loads head of mem at mempointer to head of stack\
LOADL % $ - loads last of mem at mempointer to head of stack\
STORE ($,i,f) % - appends head of stack or value to memory at %\
STOREH $ % - stores head of stack on start of memory of mempointer\
REML % - removes last of memory at mempointer\
REMH % - removes head of memory at mempointer

LABEL label - defines a label, is replaced with NOOP but will be replaced with this NOOPs instruction address everywhere else\
CALL label - stores next instructions address on %ips and then goes to label definition address\
GOTO label - continues executing at the instruction at the label definitions address \
JMP0 $ label - if head of stack is 0 GOTO label, otherwise continue\
JMP1 $ label - if head of stack is 1 GOTO label, otherwise continue\
RET - pops $ips and continues executing there\
EXIT ($,i) - exits program with the given value or head of stack\
OUT % - prints values in given interpreted as text. the runtime throws if there is a float inside

PUSH (i,f) $ - push value to stack $\
CPY $ $ - push first args head to second arg\
MOV $ $ - push first args head to second arg, pops first args head\
POP $ - pops head of $

EQ $ - pops head and head of tail from stack, compares and puts 0 on stack if unequal, 1 if equal\
EQV $ i - pops head from stack, compares value with second argument and puts 0 on stack if unequal, 1 if equal\
ADD $ - pops head and head of tail from stack adds them and put result on stack\
SUB $ - pops head and head of tail from stack subracts head of tail from head and put result on stack\
MUL $ - pops head and head of tail from stack muliplies them and put result on stack\
DIV $ - pops head and head of tail from stack divides head by head of tail and put result on stack\
MOD $ - pops head and head of tail from stack calculates modulo head by head of tail and put result on stack

AND $ - pops head and head of tail from stack and checks if both are 1, puts 1 on stack if true, 0 otherwise
OR $ - pops head and head of tail from stack and checks if one is 1, puts 1 on stack if true, 0 otherwise
