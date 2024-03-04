%{

    #include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
    #include <stdbool.h>
    #include "extra/hashtbl.h"

    extern FILE *yyin;
    extern int yylex();
    extern void yyerror(const char* err);

    HASHTBL *hashtbl;
    int scope = 0;

%}

%define parse.error verbose

%union {
    int intval;
    float doubleval;
    _Bool binval;
    char charval;
    char *strval;
}

%token T_PROGRAM	"program"
%token T_CONST		"const"
%token T_TYPE 		"type"
%token T_ARRAY 	    "array"
%token T_SET 		"set"
%token T_OF		    "of"
%token T_RECORD 	"record"
%token T_VAR 		"var"
%token T_FORWARD	"forward"
%token T_FUNCTION   "function"
%token T_PROCEDURE  "precedure"
%token T_INTEGER 	"integer"
%token T_REAL 	    "real"
%token T_BOOLEAN 	"boolean"
%token T_CHAR 		"char"
%token T_BEGIN		"begin"
%token T_END		"end"
%token T_IF 		"if"
%token T_THEN		"then"
%token T_ELSE		"else"
%token T_WHILE		"while"
%token T_DO 		"do"
%token T_FOR 		"for"
%token T_DOWNTO	    "downto"
%token T_TO 		"to"
%token T_WITH 		"with"
%token T_READ 		"read"
%token T_WRITE		"write"

/* Identifier */

%token <strval> T_ID 		"id"

/* Constants */

%token <intval>      T_ICONST 	  "iconst"
%token <realval>     T_RCONST	  "rconst"
%token <binval>      T_BCONST     "bconst"
%token <charval>     T_CCONST	  "cconst"


/* Operators */

%token T_RELOP		 "> or >= or < or <= or <>"
%token T_ADDOP		 "+ or -"
%token T_OROP		 "OR"
%token T_MULDIVANDOP "* or / or DIV or MOD or AND"
%token T_NOTOP		 "NOT"
%token T_INOP 		 "IN"

%token T_STRING	40


%token T_LPAREN	"("
%token T_RPAREN	")"
%token T_SEMI	";"	 
%token T_DOT 	"."	
%token T_COMMA	","	
%token T_EQU    "="  
%token T_COLON	":"  
%token T_LBRACK	"["	
%token T_RBRACK	"]" 	
%token T_ASSIGN	":="	
%token T_DOTDOT	".."

%token T_EOF 0  "EOF"

/*
%type  <strval> program header declarations constdefs constant_defs expression variable expressions 
%type  <strval> constant setexpression elexpressions elexpression typedefs type_defs type_def dims limits limit typename standard_type fields 
%type  <strval> field identifiers vardefs variable_defs subprograms subprogram sub_header formal_parameters parameter_list 
%type  <strval> pass comp_statement statements statement assignment if_statement if_tail while_statement for_statement 
%type  <strval> iter_space with_statement subprogram_call io_statement read_list read_item write_list write_item
*/

%left T_NOTOP
%left T_MULDIVANDOP
%left T_OROP T_ADDOP
%left T_INOP T_RELOP T_EQU

%nonassoc LOWER_THAN_ELSE
%nonassoc T_ELSE

%%

program:                    header declarations subprograms comp_statement T_DOT
                            ;

header:                     T_PROGRAM T_ID T_SEMI                                       { hashtbl_insert(hashtbl, $2, NULL, scope); }                            
                            ;

declarations:               constdefs typedefs vardefs
                            ;

constdefs:                 T_CONST constant_defs T_SEMI
                        | %empty                                                        { }
                        ;
constant_defs:             constant_defs T_SEMI T_ID T_EQU expression                   { hashtbl_insert(hashtbl, $3, NULL, scope); }
                        | T_ID T_EQU expression                                         { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        ;       
expression:                expression T_RELOP expression
                        | expression T_EQU expression
                        | expression T_INOP expression
                        | expression T_OROP expression
                        | expression T_ADDOP expression
                        | expression T_MULDIVANDOP expression
                        | T_ADDOP expression
                        | T_NOTOP expression
                        | variable
                        | T_ID T_LPAREN expressions T_RPAREN                              { hashtbl_insert(hashtbl, $1, NULL, scope); }                  
                        | constant
                        | T_LPAREN expression T_RPAREN
                        | setexpression
                        ;
variable:                  T_ID                                                   { hashtbl_insert(hashtbl, $1, NULL, scope); }                           
                        | variable T_DOT T_ID                                           { hashtbl_insert(hashtbl, $3, NULL, scope); }                                   
                        | variable T_LBRACK expressions T_RBRACK
                        ;
expressions:              expressions T_COMMA expression
                        | expression
                        ;
constant:                 T_ICONST
                        | error
                        | T_RCONST
                        | T_BCONST
                        | T_CCONST
                        ;
setexpression:              T_LBRACK elexpressions T_RBRACK
                        | T_LBRACK T_RBRACK
                        ;
elexpressions:              elexpressions T_COMMA elexpression
                        | elexpression
                        ;
elexpression:               expression T_DOTDOT expression
                        | expression
                        ;
typedefs:                  T_TYPE type_defs T_SEMI
                        | %empty                                                        { }
                        ;                        
type_defs:                 type_defs T_SEMI T_ID T_EQU type_def                         { hashtbl_insert(hashtbl, $3, NULL, scope); }              
                        | T_ID T_EQU type_def                                           { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        | error T_EQU type_def                                  {yyerror ("Wrong use in Type def"); yyerrok;}
                        | T_ID error type_def                                   {yyerror ("Wrong use in Type def"); yyerrok;}
                        | T_ID T_EQU error                                      {yyerror ("Wrong use in Type def"); yyerrok;}
                        ;                  
type_def:                  T_ARRAY T_LBRACK dims T_RBRACK T_OF typename
                        | T_SET T_OF typename
                        | T_RECORD fields T_END
                        | T_LPAREN identifiers T_RPAREN
                        | limit T_DOTDOT limit
                        ;
dims:                     dims T_COMMA limits
                        | limits
                        ;
limits:                   limit T_DOTDOT limit
                        | T_ID                                                          { hashtbl_insert(hashtbl, $1, NULL, scope); } 
                        ;                                    
limit:                   T_ADDOP T_ICONST
                        | T_ADDOP T_ID                                                  { hashtbl_insert(hashtbl, $2, NULL, scope); }                                     
                        | T_ICONST
                        | T_CCONST
                        | T_BCONST
                        | T_ID                                                             { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        ;                                                                                                  
typename:                standard_type
                        | T_ID                                                          { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        ;                                         
standard_type:            T_INTEGER | T_REAL | T_BOOLEAN | T_CHAR
                        ;
fields:                   fields T_SEMI field
                        | field
                        ;
field:                    identifiers T_COLON typename
                        ;
identifiers:              identifiers T_COMMA T_ID                                      { hashtbl_insert(hashtbl, $3, NULL, scope); }                       
                        | T_ID                                                          { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        ;                       
vardefs:                  T_VAR variable_defs T_SEMI
                        | %empty                                                        { }
                        ;
variable_defs:            variable_defs T_SEMI identifiers T_COLON typename
                        | identifiers T_COLON typename
                        ;
subprograms:              subprograms subprogram T_SEMI
                        | %empty                                                        { }
                        ;
subprogram:               sub_header T_SEMI T_FORWARD
                        | sub_header T_SEMI declarations subprograms comp_statement
                        ;
sub_header:              T_FUNCTION T_ID formal_parameters T_COLON standard_type        { hashtbl_insert(hashtbl, $2, NULL, scope); } 
                        | T_PROCEDURE T_ID formal_parameters                            { hashtbl_insert(hashtbl, $2, NULL, scope); }  
                        | T_FUNCTION T_ID                                               { hashtbl_insert(hashtbl, $2, NULL, scope); }
                        | error T_ID                                {yyerror ("Wrong use in Functions"); yyerrok;}
                        | T_FUNCTION error                          {yyerror ("Wrong use in Functions"); yyerrok;}
                        ;    
formal_parameters:       T_LPAREN parameter_list T_RPAREN                               
                        | %empty                                                        { }
                        ;
parameter_list:           parameter_list T_SEMI pass identifiers T_COLON typename
                        | pass identifiers T_COLON typename
                        ;
pass:                   T_VAR 
                        | %empty                                                        { }
                        ;
comp_statement:           T_BEGIN {scope++;} statements T_END 
                        ;
statements:               statements T_SEMI statement
                        | statement         { hashtbl_get(hashtbl, scope); scope--; }
                        ;
statement:                assignment
                        | if_statement
                        | while_statement
                        | for_statement
                        | with_statement
                        | subprogram_call
                        | io_statement
                        | comp_statement
                        | %empty                                                        { }
                        ;
assignment:               variable T_ASSIGN expression
                        | variable T_ASSIGN T_STRING
                        ;
if_statement:             T_IF expression T_THEN {scope++;} statement if_tail { hashtbl_get(hashtbl, scope); scope--; }
                        ;
if_tail:                  T_ELSE {scope++;} statement { hashtbl_get(hashtbl, scope); scope--; }
                        | %empty %prec LOWER_THAN_ELSE                                  { }
                        ;
while_statement:          T_WHILE expression T_DO statement
                        ;
for_statement:            T_FOR T_ID T_ASSIGN iter_space T_DO {scope++;} statement { hashtbl_get(hashtbl, scope); scope--;}  { hashtbl_insert(hashtbl, $2, NULL, scope); }
                        ;
iter_space:               expression T_TO expression
                        | expression T_DOWNTO expression
                        ;
with_statement:           T_WITH variable T_DO statement 
                        ;
subprogram_call:          T_ID                                                          { hashtbl_insert(hashtbl, $1, NULL, scope); }                                    
                        | T_ID T_LPAREN expressions T_RPAREN                            { hashtbl_insert(hashtbl, $1, NULL, scope); }
                        ;           
io_statement:             T_READ T_LPAREN read_list T_RPAREN
                        | T_WRITE T_LPAREN write_list T_RPAREN
                        | error T_LPAREN write_list T_RPAREN                 {yyerror ("Wrong use in header"); yyerrok;}
                        | T_WRITE error write_list T_RPAREN                  {yyerror ("Wrong use in header"); yyerrok;}
                        | T_WRITE T_LPAREN write_list error                  {yyerror ("Wrong use in header"); yyerrok;}
                        ;
read_list:                read_list T_COMMA read_item
                        | read_item
                        ;
read_item:                variable
                        ;
write_list:               write_list T_COMMA write_item
                        | write_item
                        ;
write_item:               expression
                        | T_STRING
                        ;

%%

int main(int argc, char *argv[]){
	int token;  

     if (!(hashtbl = hashtbl_create(10, NULL))) {
        puts("Error failed to initialize hashtable");
        exit (EXIT_FAILURE); 
    }     

	/* Read File */

	if(argc > 1){       
		yyin = fopen(argv[1], "r");
		if (yyin == NULL){
			perror ("[ERROR] Could not open file \'%s\', argv[1]"); 
			return EXIT_FAILURE;
		}
	}        

    yyparse();

	fclose(yyin);
    hashtbl_destroy(hashtbl);
    return 0;
}