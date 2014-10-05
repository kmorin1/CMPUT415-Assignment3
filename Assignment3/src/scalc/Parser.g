grammar Parser;

options {
  language = Java;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  MAINBLOCK;
  SUBBLOCK;
  SUBEXPR;
  STATEMENTS;
  ASSIGNMENT;
  DECLARATION;
  GENERATOR;
  INDEX;
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
  @Override
  protected Object recoverFromMismatchedToken(IntStream input, int ttype, BitSet follow) throws RuntimeException {
    throw new RuntimeException("Mismatched Token");
  }
  
  @Override
  public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
    String hdr = getErrorHeader(e);
    String msg = getErrorMessage(e, tokenNames);
    throw new RuntimeException(hdr + ":" + msg);
  }
}


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

type
  : Int
  | Vector
  ;
  
varDecl
  : type Identifier Assign expression -> ^(DECLARATION type Identifier expression)
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
  : indexExpr ((Multiply | Divide)^ indexExpr)*
  ;
  
indexExpr
  : rangeExpr (index^)*
  ;
  
rangeExpr
  : (atom Range)=> atom Range^ atom
  | atom
  ;
  
atom
  : Number
  | Identifier
  | filter
  | generator
  | LParen expression RParen -> ^(SUBEXPR expression)
  ;
  
index
	: LBracket expression RBracket -> ^(INDEX expression)
	;
  
filter
	: Filter LParen Identifier In vector=expression Bar condition=expression RParen -> ^(Filter Identifier $vector $condition)        
  ;
  
generator
	: LBracket Identifier In vector=expression Bar apply=expression RBracket -> ^(GENERATOR Identifier $vector $apply)   
	;

If      : 'if';
Fi      : 'fi';
Loop    : 'loop';
Pool    : 'pool';
Print   : 'print';
Int     : 'int';
Vector	: 'vector';
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
LBracket: '[';
RBracket: ']';
Assign  : '=';
SemiColon: ';';
Range		: '..';
Filter	: 'filter';
In			: 'in';
Bar			: '|';

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