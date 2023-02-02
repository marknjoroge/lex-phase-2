%{
#include "phase2.h"
#include "Phase2.tab.h"
#include <stdio.h>
#include <string.h> 
extern int yylineno;
%}
/* KEEP TRACK OF LINE NUMBER*/
%option yylineno
start  \"
end    \"
string {start}.*{end}
%%

"int"   {return INT;}
"float" {return FLOAT;}
"boolean" {return BOOLEAN;}
"if"      {return(IF);}
"else"    {return(ELSE);}
"end"     {return(ENDE);}
"true"    {return(TRUE);}
"false"    {return(FALSE);}
"print"   {return(PRINT);}
"while"   {return(WHILE);}
"read"    {return (READ);}
"START" {return(START);}
"END" {return(END);}
"*" {return(TIMES);}
"+" {return(PLUS);}
"=" {return(ASG);}
"&&" {return(AND);}
"||"  {return(OR);}
"!"  {return(NOT);}
"==" {return(EQ);}
"(" {return(LPAREN);}
")" {return(RPAREN);}
"{" {return(OP);}
"}" {return(CL);}
"<>" {return(NE);}
"<" {return(LT);}
"<=" {return(LE);}
">" {return(GT);}
">=" {return(GE);}
[A-Z]([a-z]|[A-Z]|_|[0-9])* {return(ID);}
{string} {return(STRING_LITERAL);}
[0-9]+ { return(INT_LITERAL);}
[0-9]*\.[0-9]+  {return(FLOAT_LITERAL);}
"##"(.|\n)*"##" {;}
[ \t\n]   {;}
.   {return ERROR;}
%%

int yywrap() {
    return 1;
}
