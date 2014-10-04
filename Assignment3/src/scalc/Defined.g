tree grammar Defined;

options {
  language = Java;
  tokenVocab = Parser;
  ASTLabelType = CommonTree;
}

@header
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

program
  : mainblock
  ;
  
mainblock
  : ^(MAINBLOCK declaration* statement*)
  ;

subblock
  : ^(SUBBLOCK statement*)
  ;

declaration
  : varDecl
  ;

statement
  : assignment
  | printStatement
  | ifStatement
  | loopStatement
  ;

type returns [Type tsym]
  : Int {$tsym = (Type)symtab.resolve("int");}
  | Vector {$tsym = (Type)symtab.resolve("vector");}
  ;
  
varDecl
  : ^(DECLARATION type Identifier expression)
  {
   
    VariableSymbol vs = new VariableSymbol($Identifier.text, $type.tsym);
    symtab.define(vs);
    if (!$type.text.equals($expression.type))
    {
      throw new RuntimeException("Incompatible types in var declaration");
    }
  }
  ;

assignment
  : ^(Assign Identifier expression)
  ;

printStatement
  : ^(Print expression)
  ;

ifStatement
  : ^(If expression subblock)
  ;

loopStatement
  : ^(Loop expression subblock)
  ;

expression returns [String type]
  : equExpr {$type = $equExpr.type;}
  ;
  
equExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Equals | NEquals) a=relExpr b=relExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=relExpr {$type = $c.type;}
  ;

relExpr returns [String type]
@init {
	$type = "int";
}
  : ^((LThan | GThan) a=addExpr b=addExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=addExpr {$type = $c.type;}
  ;
  
addExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Add | Subtract) a=mulExpr b=mulExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=mulExpr {$type = $c.type;}
  ;
  
mulExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Multiply | Divide) a=rangeExpr b=rangeExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=rangeExpr {$type = $c.type;}
  ;
  
rangeExpr returns [String type]
  : ^(Range min=unaryExpr max=unaryExpr)
  {
    if ($min.type == "vector" || $max.type == "vector")
    {
      throw new RuntimeException("Cannot use a vector with range operator '..'");
    }
    $type = "vector";
  }
  | a=unaryExpr {$type = $a.type;}
  ;
  
unaryExpr returns [String type]
  : ^(INDEX a=atom index=expression)
  {
    if ($a.type.equals("int"))
    {
      throw new RuntimeException("Can't index an integer value");
    }
    $type = $index.type;
  }
  | b=atom {$type = $b.type;}
  ;
  
atom returns [String type]
  : Number {$type = "int";}
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
  | ^(SUBEXPR expression) {$type = $expression.type;}
  ;
  
filter
	: ^(Filter Identifier
	{
	   VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)symtab.resolve("int"));
     symtab.define(vs);
  }
  vector=expression condition=expression)
  ;
  
generator
	: ^(GENERATOR Identifier  
	{
	  VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)symtab.resolve("int"));
	  symtab.define(vs);
	}
	vector=expression apply=expression) 
	;
