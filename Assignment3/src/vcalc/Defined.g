tree grammar Defined;

options {
  language = Java;
  tokenVocab = Parser;
  ASTLabelType = CommonTree;
}

@header
{
  package vcalc;
}

@members
{
  SymbolTable symtab;
  Scope currentScope;
  
  public Defined(TreeNodeStream input, SymbolTable symtab) {
    this(input);
    this.symtab = symtab;
    currentScope = symtab.globals;
  }
  
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
  : Int {$tsym = (Type)currentScope.resolve("int");}
  | Vector {$tsym = (Type)currentScope.resolve("vector");}
  ;
  
varDecl
  : ^(DECLARATION type Identifier expression)
  {
    Symbol id = currentScope.resolve($Identifier.text);
    if (id != null) {
       throw new RuntimeException("Variable " + $Identifier.text + " defined more than once");
    }
    
    VariableSymbol vs = new VariableSymbol($Identifier.text, $type.tsym);
    currentScope.define(vs);
    if (!$type.text.equals($expression.type))
    {
      throw new RuntimeException("Incompatible types in var declaration");
    }
  }
  ;

assignment
  : ^(Assign Identifier expression)
  {
    Symbol id = currentScope.resolve($Identifier.text);
    if (id == null) {
       throw new RuntimeException("Undefined variable " + $Identifier.text);
    }
    
    String idType = id.type.getName();
    if (!idType.equals($expression.type))
    {
      throw new RuntimeException("Incompatible types in var assignment");
    }
  }
  ;

printStatement
  : ^(Print expression)
  ;

ifStatement
  : ^(If expression
  {
    if ($expression.type.equals("vector")) {
       throw new RuntimeException("If statement condition must be an integer");
    }
  }
  subblock)
  ;

loopStatement
  : ^(Loop expression
  {
    if ($expression.type.equals("vector")) {
       throw new RuntimeException("Loop statement condition must be an integer");
    }
  }
  subblock)
  ;

expression returns [String type]
  : equExpr {$type = $equExpr.type;}
  ;
  
equExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Equals | NEquals) a=equExpr b=equExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=relExpr {$type = $c.type;}
  ;

relExpr returns [String type]
@init {
	$type = "int";
}
  : ^((LThan | GThan) a=relExpr b=relExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=addExpr {$type = $c.type;}
  ;
  
addExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Add | Subtract) a=addExpr b=addExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=mulExpr {$type = $c.type;}
  ;
  
mulExpr returns [String type]
@init {
	$type = "int";
}
  : ^((Multiply | Divide) a=mulExpr b=mulExpr) {if ($a.type == "vector" || $b.type == "vector") $type = "vector";}
  | c=indexExpr {$type = $c.type;}
  ;
  
indexExpr returns [String type]
  : ^(INDEX index=expression vector=indexExpr)
  {
    if ($vector.type.equals("int"))
    {
      throw new RuntimeException("Cannot index an integer value");
    }
    $type = $index.type;
  }
  | rangeExpr {$type = $rangeExpr.type;}
  ;
  
rangeExpr returns [String type]
  : ^(Range min=atom max=atom)
  {
    if ($min.type == "vector" || $max.type == "vector")
    {
      throw new RuntimeException("Cannot use a vector with range operator '..'");
    }
    $type = "vector";
  }
  | a=atom {$type = $a.type;}
  ;
  
atom returns [String type]
  : Number {$type = "int";}
  | Identifier 
  {
  	Symbol id = currentScope.resolve($Identifier.text);
  	if (id == null) {
       throw new RuntimeException("Undefined variable " + $Identifier.text);
    }
    $type = id.type.getName();        
  }
  | filter {$type = "vector";}
  | generator {$type = "vector";}
  | ^(SUBEXPR expression) {$type = $expression.type;}
  ;
  
filter
@init {
  currentScope = new LocalScope(currentScope);
}
@after {
  currentScope = currentScope.getEnclosingScope();
}
	: ^(Filter Identifier
	{
	   VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)currentScope.resolve("int"));
     currentScope.define(vs);
  }
  vector=expression
  {
    if ($vector.type.equals("int")) {
       throw new RuntimeException("Filter domain must be a vector");
    }
  }
  condition=expression
  {
    if ($condition.type.equals("vector")) {
       throw new RuntimeException("Filter predicate must be an integer");
    }
  }
  )
  ;
  
generator
@init {
  currentScope = new LocalScope(currentScope);
}
@after {
  currentScope = currentScope.getEnclosingScope();
}
	: ^(GENERATOR Identifier  
	{
	  VariableSymbol vs = new VariableSymbol($Identifier.text, (Type)currentScope.resolve("int"));
	  currentScope.define(vs);
	}
	vector=expression
	{
    if ($vector.type.equals("int")) {
       throw new RuntimeException("Generator domain must be a vector");
    }
  }
  apply=expression
  {
    if ($apply.type.equals("vector")) {
       throw new RuntimeException("Generator right hand side must be an integer");
    }
  }
  ) 
	;
