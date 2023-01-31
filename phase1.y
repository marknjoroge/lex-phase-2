%{
#include "phase2.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
int yylex();
extern FILE* yyin;
extern int yylineno;
extern int yyerror (char* msg);
extern char * yytext;
int varcount=0;
int curscope=0;
%}

/* definitions section start */

%union {struct variable symp;}
%token<symp> INT FLOAT BOOLEAN
%token IF ELSE END TRUE FALSE READ PRINT WHILE START 
%token INT_LITERAL FLOAT_LITERAL STRING_LITERAL ID ERROR

%right ASSIGN

%left MUL DIV
%left ADD SUB
%left LPAREN RPAREN
%left LBRACE RBRACE
%left LT LEQ GT GEQ
%left EQ NEQ
%left LOG_AND
%left LOG_OR

%nonassoc LOG_NOT
%type<symp> expression exp factor TYPE ID

%start program

/* definitions section end */

%%

/* rules section start */

program         : START statements END {printf("No syntax errors detected")};

statements      : statements statement
                | statement
                ;

statement       : dec_stmt
                | assignment_stmt
                | print_stmt
                | read_stmt
                | condition_stmt
                | while_stmt
                ;

dec_stmt        : TYPE ID {
                        if (findvarInScop($2.name, curscope) == 1) 
                            semanticerror("Declaration Error: Variable already declared.");
                        insertvar($2.name, $1.name);
                        varcount++;
                    }
                ;

TYPE            : INT
                | FLOAT
                | BOOLEAN
                ;

assignment_stmt : ID ASSIGN expression {
                        if (strcmp(findtype($1.name, curscope), "XXX") != 0) 
                            semanticerror("Initialision Error: Variable not declared.");
                        if (sizeof($1) != sizeof($3))
                            semanticerror("Type Error: Types do not match");
                    }
                ;

expression      : exp EQ exp { 
                        if(sizeof($1) == sizeof($3))
                            $$=$1==$3;
                        else
                            semanticerror("Type Error: Can not compare non boolean values."); 
                    }
                | exp NEQ exp { 
                        if(sizeof($1) == sizeof($3))
                            $$=$1!=$3;
                        else
                            semanticerror("Type Error: Can not compare non boolean values."); 
                    }
                | exp
                ;

exp             : exp MUL exp { 
                        if ((strcmp(findtype($1.name, curscope), "int") 
                                || strcmp(findtype($1.name, curscope), "float"))
                            && (strcmp(findtype($3.name, curscope), "int") 
                                || strcmp(findtype($3.name, curscope), "int")) )

                            $$ = $1 * $3; 
                    }
                | exp ADD exp { 
                        if ((strcmp(findtype($1.name, curscope), "int") 
                                || strcmp(findtype($1.name, curscope), "float"))
                            && (strcmp(findtype($3.name, curscope), "int") 
                                || strcmp(findtype($3.name, curscope), "int")) )
                                
                            $$ = $1 + $3; 
                    }
                | exp LOG_AND exp { $$ = $1 && $3; }
                | factor
                ;

factor          : LPAREN exp RPAREN { $$ = $2;curscope++; }
                | INT_LITERAL {
                        strcpy($$.type ,"int");
                        strcpy($$.name,"");   
                    }
                | FLOAT_LITERAL {
                        strcpy($$.type ,"float");
                        strcpy($$.name,"");   
                    }
                | ID
                | TRUE {
                        strcpy($$.type ,"bool");
                        strcpy($$.name,"");   
                    }
                | FALSE {
                        strcpy($$.type ,"bool");
                        strcpy($$.name,"");   
                    }
                ;

print_stmt      : PRINT LPAREN ID RPAREN
                | PRINT LPAREN STRING_LITERAL RPAREN
                ;

read_stmt       : ID ASSIGN READ LPAREN RPAREN
                ;

condition_stmt  : IF LPAREN expression RPAREN LBRACE statements RBRACE END {
                        if (sizeof($3) != 1) semanticerror("Type Error: Condition is not a Boolean.");
                    }
                | IF LPAREN expression RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE END {
                        if (sizeof($3) != 1) semanticerror("Type Error: Condition is not a Boolean.");
                    }
                ;

while_stmt      : WHILE LPAREN expression RPAREN LBRACE statements RBRACE {
                        if (sizeof($3) != 0) semanticerror("Type Error: Condition is not a Boolean.");
                    }
                ;

/* rules section end */

%%

/* auxiliary routines start */

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r" );
    if(!yyparse())
            printf("\nParsing complete\n");
        else
            printf("\nParsing failed\n");
        
        fclose(yyin);

    return 0;
}

int yyerror (char* msg) {
    printf("Line %d: %s near %s\n", yylineno, msg, yytext);
    exit(1);
}

void semanticerror (char* msg) {
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




/* auxiliary routines end */