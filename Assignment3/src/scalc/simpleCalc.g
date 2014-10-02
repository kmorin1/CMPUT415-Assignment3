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
  GENERATOR;
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
    throw new RuntimeException("Mismatched Token");
  }
  
  @Override
  public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
    String hdr = getErrorHeader(e);
    String msg = getErrorMessage(e, tokenNames);
    throw new RuntimeException(hdr + ":" + msg);
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
  | Vector {$tsym = (Type)symtab.resolve("vector");}
  ;
  
varDecl
  : type Identifier Assign expression
  {
    VariableSymbol vs = new VariableSymbol($Identifier.text, $type.tsym);
    symtab.define(vs);
    if (!$type.text.equals($expression.type))
    {
      throw new RuntimeException("Incompatible types in var declaration");
    }
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

expression returns [String type]
  : equExpr {$type = $equExpr.type;}
  ;
  
equExpr returns [String type]
@init {
	$type = "int";
}
  : a=relExpr {if ($a.type == "vector") $type = "vector";}
  ((Equals | NEquals)^ b=relExpr {if ($b.type == "vector") $type = "vector";})*
  ;

relExpr returns [String type]
@init {
	$type = "int";
}
  : a=addExpr {if ($a.type == "vector") $type = "vector";}
  ((LThan | GThan)^ b=addExpr {if ($b.type == "vector") $type = "vector";})* 
  ;
  
addExpr returns [String type]
@init {
	$type = "int";
}
  : a=mulExpr {if ($a.type == "vector") $type = "vector";}
  ((Add | Subtract)^ b=mulExpr {if ($b.type == "vector") $type = "vector";})*
  ;
  
mulExpr returns [String type]
@init {
	$type = "int";
}
  : a=unaryExpr {if ($a.type == "vector") $type = "vector";}
  ((Multiply | Divide)^ b=unaryExpr {if ($b.type == "vector") $type = "vector";})*
  ;
  
unaryExpr returns [String type]
  : LParen expression RParen {$type = $expression.type;} -> expression 
  | atom {$type = $atom.type;}
  ;
  
atom returns [String type]
  : Number Range Number {$type = "vector";}
  | Number {$type = "int";}
  | Identifier 
  {
  	Symbol id = symtab.resolve($Identifier.text);
  	if (id == null) {
       throw new RuntimeException("Undefined variable " + $Identifier.text);
    }
    $type = id.getTypeName();          
  }
  | filter {$type = "vector";}
  | generator {$type = "vector";}
  ;
  
filter
	: Filter LParen Identifier 
	{
	   VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)symtab.resolve("int"));
     symtab.define(vs);
  }
     In vector=expression Bar condition=expression RParen -> ^(Filter Identifier $vector $condition)        
  ;
  
generator
	: LBracket Identifier 
	{
	  VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)symtab.resolve("int"));
	  symtab.define(vs);
	}
	  In vector=expression Bar apply=expression RBracket -> ^(GENERATOR Identifier $vector $apply)   
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