# Simple Compiler Documentation

## Overview

This document describes a simple compiler implemented using Flex (for lexical analysis) and Bison (for parsing) in C. The compiler is designed to process a basic programming language with features such as variable declarations, assignments, conditional statements, loops, and print statements.

## Language Structure

The compiler can process programs with the following structure:

```
START 
int X12
float ABC1
ABC1 = 2 + 2.33
while ( X12 == 0 )
{
    ABC1 = 4.5

    if ( true )
    { print ( " Inside IF inside Loop " ) }
    end
}
print ( " Hello .. " )
END
```

## Compiler Components

### 1. Lexical Analyzer (Phase2.l)

The lexical analyzer is implemented using Flex. It defines the tokens of the language, including:

- Keywords: START, END, int, float, while, if, print, true, false
- Identifiers: Variable names (e.g., X12, ABC1)
- Operators: =, ==, +
- Literals: Integer and float constants, strings
- Special symbols: (, ), {, }

### 2. Parser (Phase2.y)

The parser is implemented using Bison. It defines the grammar of the language and specifies the actions to be taken for each production rule. The main components include:

- Variable declaration rules
- Assignment statements
- While loop structure
- If statement structure
- Print statement
- Expression handling

## How to Run the Compiler

The compiler can be built and run using the provided shell script. Here's a breakdown of the script:

```bash
#! /bin/sh

# Clean up previous builds
gio trash lex.yy.c Phase2.tab.c Phase2.tab.h

# Generate lexical analyzer
flex Phase2.l

# Generate parser
bison -d -t Phase2.y

# Compile the generated C files
gcc Phase2.tab.c lex.yy.c -ly -ll

# Run the compiler with input file
./a.out < myP3.txt
```

### Steps:

1. Clean up any previously generated files.
2. Use Flex to generate the lexical analyzer (lex.yy.c) from Phase2.l.
3. Use Bison to generate the parser (Phase2.tab.c and Phase2.tab.h) from Phase2.y.
4. Compile the generated C files along with the necessary libraries.
5. Run the resulting executable with an input file (myP3.txt in this case).

## Input Files

The script is set up to use myP3.txt as the input file, but it also mentions other potential input files (myP.txt, myP1.txt, myP2.txt). These likely contain different test programs to verify various aspects of the compiler.

## Usage

1. Ensure you have Flex, Bison, and GCC installed on your system.
2. Save your input program in a text file (e.g., myP3.txt).
3. Run the shell script to build and execute the compiler:
   ```
   ./compile_and_run.sh
   ```
4. The compiler will process the input file and produce output based on the implemented actions in the Bison file.

## Customization

- To use a different input file, modify the last line of the shell script to point to your desired input file.
- To add new language features, you'll need to update both the Phase2.l (to recognize new tokens) and Phase2.y (to handle new grammar rules) files.

## Troubleshooting

- If you encounter "command not found" errors, ensure Flex, Bison, and GCC are properly installed and in your system's PATH.
- If you get syntax errors, check your input file against the expected language structure outlined above.

## Conclusion

This simple compiler demonstrates the basic principles of lexical analysis and parsing using Flex and Bison. It can be extended to handle more complex language features, perform semantic analysis, and generate intermediate or machine code.
