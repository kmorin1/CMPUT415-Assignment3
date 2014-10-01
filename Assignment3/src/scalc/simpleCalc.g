grammar simpleCalc;

options {
  language = Java;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  MAINBLOCK;
  SUBBLOCK;
  STATEMENTS;
  ASSIGNMENT;
  DECLARATION;
}

@header
{
  package scalc;
}

@lexer::header
{
  package scalc;
}

@members
{
  SymbolTable symtab = new SymbolTable();
  
  @Override
  protected Object recoverFromMismatchedToken(IntStream input, int ttype, BitSet follow) throws RuntimeException {
    throw new RuntimeException("");
  }
}

compilationUnit[SymbolTable symtab]

@init
{
  this.symtab = symtab;
} : varDecl*
  ;

program
  : mainblock EOF -> mainblock
  ;
  
mainblock
  : declaration* statement* -> ^(MAINBLOCK declaration* statement*)
  ;

subblock
  : statement* -> ^(SUBBLOCK statement*)
  ;

declaration
  : varDecl SemiColon -> varDecl
  ;

statement
  : assignment SemiColon -> assignment
  | printStatement SemiColon -> printStatement
  | ifStatement SemiColon -> ifStatement
  | loopStatement SemiColon -> loopStatement
  ;

type returns [Type tsym]
  : Int {$tsym = (Type)symtab.resolve("int");}
  ;
  
varDecl
  : type Identifier Assign expression
    {
     VariableSymbol vs = new VariableSymbol($Identifier.text, $type.tsym);
     symtab.define(vs);
    }
    -> ^(DECLARATION Identifier expression)
  ;

assignment
  : Identifier Assign expression -> ^(Assign Identifier expression)
  ;

printStatement
  : Print LParen expression RParen -> ^(Print expression)
  ;

ifStatement
  : If LParen expression RParen subblock Fi -> ^(If expression subblock)
  ;

loopStatement
  : Loop LParen expression RParen subblock Pool -> ^(Loop expression subblock)
  ;

expression
  : equExpr
  ;
  
equExpr
  : relExpr ((Equals | NEquals)^ relExpr)*
  ;

relExpr
  : addExpr ((LThan | GThan)^ addExpr)* 
  ;
  
addExpr
  : mulExpr ((Add | Subtract)^ mulExpr)*
  ;
  
mulExpr
  : unaryExpr ((Multiply | Divide)^ unaryExpr)*
  ;
  
unaryExpr
  : LParen expression RParen -> expression
  | atom
  ;
  
atom
  : Number
  | Identifier {if (symtab.resolve($Identifier.text) == null)
                  throw new RuntimeException("");}
  ;

If      : 'if';
Fi      : 'fi';
Loop    : 'loop';
Pool    : 'pool';
Print   : 'print';
Int     : 'int';
Add     : '+';
Subtract: '-';
Multiply: '*';
Divide  : '/';
Equals  : '==';
NEquals : '!=';
GThan   : '>';
LThan   : '<';
LParen  : '(';
RParen  : ')';
Assign  : '=';
SemiColon: ';';

Number 
  : Digit+
  ;

Identifier
  : ('A'..'Z' | 'a'..'z')
  ('A'..'Z'
  | 'a'..'z'
  | Digit)*
  ;

fragment Digit
  : '0'..'9'
  ;
  
Space
  : (' ' 
  | '\t' 
  | '\r' 
  | '\n') {$channel = HIDDEN;}
  ;

Ignore
  : .
  ;