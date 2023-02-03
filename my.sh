#! /bin/sh

gio trash lex.yy.c Phase2.tab.c Phase2.tab.h

flex Phase2.l
bison -d -t Phase2.y
gcc Phase2.tab.c lex.yy.c -ly -ll
# ./a.out < myP.txt
# ./a.out < myP1.txt
# ./a.out < myP2.txt
./a.out < myP3.txt