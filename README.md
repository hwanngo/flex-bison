# flex-bison

`flex-bison` is a small command-line parser project built with Flex and Bison. It compiles a lexer from `sum.l`, a parser from `sum.y`, links them into a `sum` executable, then lets you type expressions on stdin and see evaluated results.

This repo is best understood as a learning or demo project for lexer/parser generation, not a production calculator. The code is intentionally tiny, which makes it easy to see the full pipeline from tokenization to parsing to evaluation.

## What this project does

The executable reads input line by line and passes it through a Flex scanner and a Bison grammar:

1. Flex tokenizes numbers, punctuation, parentheses, operators, and newline boundaries.
2. Bison parses those tokens into an `Expression`.
3. Grammar actions evaluate the expression immediately.
4. When a line finishes, the program prints the computed result.

The entry point is in `sum.y`, where `main()` calls `yyparse()`.

## Repository layout

This repository is intentionally minimal.

```text
.
├── Makefile   # Build and run commands
├── sum.l      # Flex lexer rules
└── sum.y      # Bison grammar, evaluation actions, main()
```

## How it works

### 1. Lexer: `sum.l`

The lexer recognizes:

- whitespace, which it ignores
- integers
- `-`
- `+`
- `,`
- `(` and `)`
- newline, which marks the end of an input line
- the literal word `exit`, which terminates the program

Notable lexer behavior:

- Integers are returned as the `NUMBER` token.
- Newline is returned as `END`, which the parser uses to know when to print a result.
- Typing `exit` immediately calls `exit(0)` from the lexer.

### 2. Parser: `sum.y`

The parser defines the token set and the grammar used by the REPL.

Top-level flow:

- `Input` accepts zero or more `Line` values.
- `Line` is either a blank line or an `Expression` followed by `END`.
- When a full expression is parsed, it prints the value with `printf("> %d\n", $1);`.

### 3. Evaluation rules

The grammar evaluates expressions directly inside parser actions.

Current expression behavior in the checked-in code:

- `NUMBER` returns its numeric value.
- `Expression SEPARATOR Expression` adds the two sides together.
- unary `+expr` returns `expr`.
- unary `-expr` returns `0`.
- `(expr)` returns `expr`.
- `()` returns `0`.

## Important behavior note

This is the most surprising thing in the repository.

Although the lexer recognizes `+` and `-`, the grammar does **not** implement conventional binary addition and subtraction. Instead:

- the comma token `,` is the only binary operator that combines two expressions
- unary plus works as a pass-through
- unary minus returns `0`, not a negated value

So this project behaves more like a grammar experiment than a normal arithmetic calculator.

Examples based on the current grammar:

- `1,2` → `3`
- `+5` → `5`
- `-5` → `0`
- `(1,2)` → `3`
- `()` → `0`

If you expected `1+2` or `5-3` to work, that logic is not present in the current grammar.

## Build requirements

The `Makefile` assumes you have these tools installed:

- `make`
- `bison`
- `flex`
- `gcc`
- the Flex runtime library for linking (`-lfl`)
- the math library (`-lm`)

On many Linux systems you may need packages such as:

- `build-essential`
- `flex`
- `bison`
- `libfl-dev`

On macOS, you may need to install newer versions of Flex and Bison via Homebrew if the system versions are missing or outdated.

## Build and run

### Build the executable

```bash
make calc
```

What this does:

1. runs `bison -d sum.y`
2. runs `flex sum.l`
3. compiles the generated C files with `gcc`
4. produces the executable `sum`
5. deletes the generated intermediary files:
   - `sum.tab.c`
   - `sum.tab.h`
   - `lex.yy.c`

### Current build status

The repository's intended build command is `make calc`, but the checked-in source does not build cleanly on stricter modern C toolchains without fixes.

During verification on this machine, `make calc` failed with implicit-declaration errors involving:

- `yylex`
- `yyerror`
- `exit`

In practice, that means the project currently documents a parser pipeline correctly, but may require small source updates before it compiles successfully in a modern environment.

### Run the program

```bash
make run
```

This target is intended to build `sum` first, then launch it. It depends on the build succeeding.

## Example session

The session below reflects the grammar's runtime behavior once the program is compiled successfully.

```text
$ make run
1,2
> 3
(1,2)
> 3
+7
> 7
-7
> 0
exit
```

## Development notes

### Generated files

During the build, these generated files are created temporarily:

- `sum.tab.c`
- `sum.tab.h`
- `lex.yy.c`

The current `Makefile` removes them after linking, so the repository stays clean and only the final `sum` binary remains.

### Error handling

The parser defines `yyerror(char *s)` in `sum.y`.

Current behavior:

- it prints the parser error message
- it exits the process immediately

That keeps the program simple, but it also means parse errors end the session instead of letting the user recover and continue.

### Compatibility note

The current codebase is written in an older, very minimal style. On modern compilers, you may need to add explicit declarations or headers before the project will build cleanly.

The missing pieces visible from the source are:

- `#include <stdlib.h>` for `exit`
- declarations for `yylex()` and `yyerror()` that satisfy the compiler

### Numeric type details

There is a type mismatch in the current implementation:

- the lexer assigns token values with `atof(yytext)`
- the parser prints results with `%d`

Because the grammar and tokens do not declare richer semantic value types, this project should be treated as a small demo rather than a numerically rigorous calculator.

## How to change the grammar

If you want to extend the language, the main places to edit are:

- `sum.l` to add or change tokens
- `sum.y` to add grammar rules and evaluation behavior
- `Makefile` if you want different build targets or compiler flags

Typical workflow:

1. edit `sum.l` and/or `sum.y`
2. run `make calc`
3. run `./sum` or `make run`
4. try sample inputs manually

## Suggested next improvements

If this repo is meant to become a more realistic calculator, the next likely steps are:

1. add real binary `+` and `-` grammar rules
2. define explicit semantic value types in Bison
3. make unary minus return a negated value instead of `0`
4. preserve REPL execution after parse errors
5. add automated tests with known input/output cases
6. avoid suppressing compiler warnings during the `gcc` step

## Summary

This project demonstrates the basic Flex/Bison toolchain in the smallest useful form:

- tokenization in `sum.l`
- parsing and evaluation in `sum.y`
- a tiny build pipeline in `Makefile`

It is easy to read end to end, which makes it a good teaching repo for generated parsers. The tradeoff is that the current grammar is intentionally limited and a little odd, so the README should be read as documentation of the code as it exists today, not as a promise of a full calculator.
