calc: sum.y sum.l
	bison -d sum.y
	flex sum.l
	gcc -w -o sum lex.yy.c sum.tab.c -lfl -lm
