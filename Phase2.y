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

void printTable();
void  yyerror();
%}

%union {struct variable symp;}
%token START LPAREN RPAREN OP CL END COMMA ENDE
%token INT_LITERAL
%token FLOAT_LITERAL
%token STRING_LITERAL TRUE FALSE ERROR
%token IF ELSE READ PRINT WHILE
%token TIMES PLUS ASG
%token EQ NE LT LE GT GE AND OR NOT 
%token ID INT FLOAT BOOLEAN
%right ASG
%left OR
%left AND
%left EQ NE
%left PLUS
%left TIMES
%nonassoc NOT
%type<symp> bexpression expression exp factor Type ID
%type<symp> INT FLOAT BOOLEAN
%%

Start_Program   : START statements END

statements      : statements statement
                | statement 
                ;

statement       : Dec_stmt | assignment_stmt |  print_stmt  |read_stmt|  condition_stmt  | while_stmt  ;

Dec_stmt        : Type ID  {
                        if (findvarInScop(yytext, curscope) == 1) 
                             yyerror("\nDeclaration Error: Variable already declared");
                        else {
                            
                            insertvar(yytext, $1.name);
                        }
                    }
                ;

Type            : INT { strcpy($$.name, "int"); }
                | FLOAT  { strcpy($$.name, "float"); }
                | BOOLEAN  { strcpy($$.name, "boolean"); }
                ;

assignment_stmt : ID ASG bexpression {
                                                 if (findvarInScop(yylval.symp.name, curscope) == 0) {
                            char msg[] = "Initialision Error: Variable ";
                            strcat(msg, yylval.symp.name);
                            strcat(msg, " not declared");
                             yyerror(msg);
                        }
                        else if (strcmp(findtype(yylval.symp.name, curscope), $3.type) != 0) {
                            char msg[30] = "Type Error: ";
                            strcat(msg, findtype(yylval.symp.name, curscope));
                            strcat(msg, " incompatible to ");
                            strcat(msg, $3.type);
                             yyerror(msg);
                        }
                    }
                ;

bexpression     : bexpression AND expression { 
                        if(strcmp($1.type, $3.type) != 0){
                            char msg[] = "Type Error: Can not compare non boolean values. Comparing ";
                            strcat(msg, $1.type);
                            strcat(msg, " to ");
                            strcat(msg, $3.type);
                             yyerror(msg);
                        } else {
                            strcpy($$.type, "bool");
                        }
                    }   
                | expression             
                ;

expression      : exp EQ exp { 
                        if(strcmp($1.type, $3.type) != 0){
                            char msg[] = "Type Error: Can not compare non boolean values. Comparing ";
                            strcat(msg, $1.type);
                            strcat(msg, " to ");
                            strcat(msg, $3.type);
                             yyerror(msg);
                        } else {
                            strcpy($$.type, "bool");
                        }
                    }   
                | exp NE exp { 
                        if(strcmp($1.type, $3.type) != 0){
                            char msg[] = "Type Error: Can not compare non boolean values. Comparing ";
                            strcat(msg, $1.type);
                            strcat(msg, " to ");
                            strcat(msg, $3.type);
                             yyerror(msg);
                        } else {
                            strcpy($$.type, "bool");
                        }
                    }
                | exp {
                            strcpy($$.type, $1.type);
                        }
                ;
            
exp             : exp PLUS exp   { 
                        if (strcmp($1.type, "float") == 0 || strcmp($3.type, "float") == 0)
                            strcpy($$.type, "float");
                    }                  
                | exp TIMES exp { 
                        if (strcmp($1.type, "float") == 0 || strcmp($3.type, "float") == 0)
                            strcpy($$.type, "float");

                    }
                | factor
                ;

factor          : LPAREN exp RPAREN { curscope++; }
                | INT_LITERAL  {
                        strcpy($$.type ,"int");
                    }
                | FLOAT_LITERAL  {
                        strcpy($$.type ,"float");
                    }
                | TRUE {
                        strcpy($$.type ,"bool");
                    }
                | FALSE {
                        strcpy($$.type ,"bool");
                    }
                | ID { 
                        strcpy($$.name, yytext);
                        if(findvarInScop(yytext, curscope)) {
                            strcpy($$.type, findtype(yytext, curscope));
                        }
                    }
                ;

print_stmt      : PRINT LPAREN ID RPAREN 
                | PRINT LPAREN STRING_LITERAL RPAREN
                ;

condition_stmt  : if_head statements CL ENDE 
                | if_head statements CL ENDE ELSE OP statements CL ENDE 
                ;

if_head         : IF LPAREN bexpression RPAREN OP {
                        if (strcmp($3.type, "bool") != 0)
                             yyerror("Type Error: Condition is not a Boolean");
                    }
                ;

while_stmt      : while_head statements CL ;

while_head      : WHILE LPAREN bexpression RPAREN OP { 
                        curscope++; 
                        printf("scope++"); 

                        if (strcmp($3.type, "bool") != 0)
                             yyerror("Type Error: Condition is not a Boolean");
                    }

read_stmt       : ID ASG READ LPAREN RPAREN;

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
    printf("\nLine %d: %s near %s\n", yylineno, msg, yytext);
}

int findvar(char name[], int scope) {
    
    for (int i = 0; i < varcount; i++) {
        if (strcmp(var[i].name, name) == 0) 
            return 1;
    }
    return 0;
}

int findvarInScop(char name[], int scope) {
    int myscope = scope;
    
    if (findvar(name, scope) == 1) {
        for (int i = 0; i < varcount; i++) {
            if (var[i].scope == scope)
                return 1;
        }
    }
    return 0;
}

void insertvar(char name[], char type[]) {

    if(findvarInScop(name, curscope)) return;
    if (findtype(name, curscope) != type) {
        strcpy(var[varcount].name, name);
        strcpy(var[varcount].type, type);
        var[varcount].scope = curscope;
        varcount++;
        return ;
    }
}

char* findtype(char name[], int scope) {

    if (findvarInScop(name, scope) == 1) {
        for (int i = 0; i < varcount; i++) {
            if (strcmp(var[i].name, name) == 0 && var[i].scope == scope) 
                return var[i].type;
        }
    }
    return "XXX";
}

