tree grammar Interpreter;

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
  SymbolTable symtab;
  Scope currentScope;
  Helper helper = new Helper();
  
  public Interpreter(TreeNodeStream input, SymbolTable symtab) {
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
  : Int {$tsym = (Type)symtab.globals.resolve("int");}
  | Vector {$tsym = (Type)symtab.globals.resolve("vector");}
  ;
  
varDecl
  : ^(DECLARATION type Identifier expression)
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
    vs.value = $expression.value;
  }
  ;

assignment
  : ^(Assign Identifier expression)
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
    vs.value = $expression.value;
  }
  ;

printStatement
  : ^(Print expression) {System.out.println($expression.value);}
  ;

ifStatement
  : ^(If expression subblock)
  ;

loopStatement
  : ^(Loop expression subblock)
  ;

expression returns [ReturnValue value]
  : ^(Equals a=expression b=expression) {$value = helper.equals($a.value, $b.value);}
  | ^(NEquals a=expression b=expression)
  | ^(LThan a=expression b=expression)
  | ^(GThan a=expression b=expression)
  | ^(Add a=expression b=expression)
  | ^(Subtract a=expression b=expression)
  | ^(Multiply a=expression b=expression)
  | ^(Divide a=expression b=expression)
  | ^(INDEX index=expression vector=expression)
  | ^(Range min=atom max=atom) {$value = helper.range($min.value, $max.value);}
  | a=atom {$value = $a.value;}
  ;
  
atom returns [ReturnValue value]
  : Number {$value = new ReturnInt(Integer.parseInt($Number.text));}
  | Identifier
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
    $value = vs.value;
  }
  | filter {$value = $filter.value;}
  | generator {$value = $generator.value;}
  | ^(SUBEXPR expression) {$value = $expression.value;}
  ;
  
filter returns [ReturnValue value]
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
  vector=expression condition=expression)
  ;
  
generator returns [ReturnValue value]
@init {
  currentScope = new LocalScope(currentScope);
  VariableSymbol vs = null;
}
@after {
  currentScope = currentScope.getEnclosingScope();
}
	: ^(GENERATOR Identifier  
	{
	  vs = new VariableSymbol($Identifier.text, (Type)currentScope.resolve("int"));
	  currentScope.define(vs);
	}
	vector=expression apply=expression)
	{
	  
	} 
	;
