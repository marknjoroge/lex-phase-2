#! /bin/sh

gio trash lex.yy.c Phase2.tab.c Phase2.tab.h

flex Phase2.l
bison -d Phase2.y
gcc Phase2.tab.c lex.yy.c
./a.out < myP.txt