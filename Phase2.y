%{
#include "phase2.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
extern int yylineno;
extern FILE* yyin;
extern int yylex();
extern char* yytext;
extern void yyerror(char *msg);
int varcount=0;
int curscope=0;
struct variable var[20];
%}

%union {struct variable symp;}
%token START LPAREN RPAREN OP CL END COMMA ENDE
%token INT_LITERAL
%token FLOAT_LITERAL
%token STRING_LITERAL TRUE FALSE ERROR
%token IF ELSE READ PRINT WHILE
%token TIMES PLUS ASG
%token EQ NE LT LE GT GE AND OR NOT 
%token ID
%right ASG
%left OR
%left AND
%left EQ NE
%left PLUS
%left TIMES
%nonassoc NOT
%type<symp> bexpression expression exp factor Type ID
%token<symp> INT FLOAT BOOLEAN
%%

Start_Program: START statements END;
statements : statements statement;
           | statement ;
statement : Dec_stmt | assignment_stmt |  print_stmt  |read_stmt|  condition_stmt  | while_stmt  ;
Dec_stmt: Type ID  {
                        if (findvarInScop($2.name, curscope) == 1) 
                            semantic_error("Declaration Error: Variable already declared.");
                        else {
                            insertvar($2.name, $1.name);
                            varcount++;
                        }
                    }
        ;
Type : INT 
|FLOAT 
|BOOLEAN 
assignment_stmt : ID ASG bexpression {
                        if (strcmp(findtype($1.name, curscope), "XXX") != 0) 
                            semantic_error("Initialision Error: Variable not declared.");
                        if (sizeof($1) != sizeof($3))
                            semantic_error("Type Error: Types do not match");
                    };
bexpression:bexpression AND expression
|expression             ;
expression : exp EQ exp { 
                        if(sizeof($1) == sizeof($3))
                            // $$=$1==$3;
                            printf("All good");
                        else
                            semantic_error("Type Error: Can not compare non boolean values."); 
                    }   
            | exp NE exp { 
                        if(sizeof($1) == sizeof($3))
                            // $$=$1!=$3;
                            printf("All good");
                        else
                            semantic_error("Type Error: Can not compare non boolean values."); 
                    }
            | exp
            ;
            
exp : exp PLUS exp   { 
                        if ((strcmp(findtype($1.name, curscope), "int") 
                                || strcmp(findtype($1.name, curscope), "float"))
                            && (strcmp(findtype($3.name, curscope), "int") 
                                || strcmp(findtype($3.name, curscope), "int")) )
                                
                            printf("All good");
                            // $$ = $1 + $3; 
                    }                  
    | exp TIMES exp { 
                        if ((strcmp(findtype($1.name, curscope), "int") 
                                || strcmp(findtype($1.name, curscope), "float"))
                            && (strcmp(findtype($3.name, curscope), "int") 
                                || strcmp(findtype($3.name, curscope), "int")) )

                            printf("All good");
                            // $$ = $1 * $3; 
                    }
    | factor                        
    ;
factor:LPAREN exp RPAREN { $$ = $2;curscope++; }
    |INT_LITERAL  {
                            strcpy($$.type ,"int");
                            strcpy($$.name,"");   
                        }
                    
    |FLOAT_LITERAL  {
                        strcpy($$.type ,"float");
                        strcpy($$.name,"");   
                    }
    |TRUE {
                        strcpy($$.type ,"bool");
                        strcpy($$.name,"");   
                    }
    |FALSE {
                        strcpy($$.type ,"bool");
                        strcpy($$.name,"");   
                    }

    | ID 
    ;
print_stmt : PRINT LPAREN ID RPAREN 
| PRINT LPAREN STRING_LITERAL RPAREN
;
condition_stmt:if_head statements CL ENDE 
              |if_head statements CL ENDE ELSE OP statements CL ENDE ;
if_head : IF LPAREN bexpression RPAREN OP {
                        if (sizeof($3) != 1) semantic_error("Type Error: Condition is not a Boolean.");
                    }
                    ;
while_stmt : WHILE LPAREN bexpression RPAREN OP statements CL {
                        if (sizeof($3) != 0) semantic_error("Type Error: Condition is not a Boolean.");
                    }
            ;
read_stmt: ID ASG READ LPAREN RPAREN;

%%
int main(int argc, char *argv[]){

    yyin = fopen(argv[1], "r");

    if(!yyparse())
            printf("\nParsing complete\n");
    else
        printf("\nParsing failed\n");
    
    fclose(yyin);

    return 0;
}

void yyerror (char* msg) {
    printf("Line %d: %s near %s\n", yylineno, msg, yytext);
}

void semantic_error (char msg[]) {
    printf("Line %d: %s near %s\n", yylineno, msg, yytext);
}

int findvar(char name[], int scope) {
    
    for (int i = 0; i < varcount; i++) {
        if (strcmp(var[i].name, name) == 0) 
            return 1;
    }
    return 0; //not found
}

int findvarInScop(char name[], int scope) {
    int myscope = scope;
    
    if (findvar(name, scope) == 1) {
        for (int i = 0; i < varcount; i++) {
            if (var[i].scope <= scope)
                return 1;
        }
    }
    return 0; //not found
}

void insertvar(char name[], char type[]) {

    if (findtype(name, curscope) != type) {
        strcpy(var[varcount].name, name);
        strcpy(var[varcount].type, type);
        var[varcount].scope = curscope;
        return ;
    }
}

char* findtype(char name[], int scope) {

    if (findvarInScop(name, scope) == 1) {
        for (int i = 0; i < varcount; i++) {
            if (var[i].name == name && var[i].scope <= scope) return var[i].type;
        }
    }
    return "XXX"; //not found
}

