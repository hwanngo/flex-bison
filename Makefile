.PHONY: run

run: calc
	@./sum

calc: sum.y sum.l
	@bison -d sum.y
	@flex sum.l
	@gcc -w -o sum lex.yy.c sum.tab.c -lfl -lm
	@rm sum.tab.c sum.tab.h lex.yy.c

