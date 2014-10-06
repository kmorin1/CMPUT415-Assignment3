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
  boolean conditional = true;
  
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
    if (conditional) {
      VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
      vs.value = $expression.value;
    }
  }
  ;

printStatement
  : ^(Print expression)
  {
    if (conditional) {
      System.out.println($expression.value);
    }
  }
  ;

ifStatement
@init {
  boolean localconditional = conditional;
}
  : ^(If expression {if (helper.equalsZero($expression.value)) {conditional = false;}} subblock) 
     {conditional = localconditional;} 
  ;
  
loopStatement
@init {
  boolean localconditional = conditional;
  int localmarker = input.mark();
}
  : ^(Loop expression {if (helper.equalsZero($expression.value)) {conditional = false;}} subblock) 
     {if (conditional) input.rewind(localmarker);} 
     {conditional = localconditional;}
  ;

expression returns [ReturnValue value]
  : ^(Equals a=expression b=expression) {$value = helper.equals($a.value, $b.value);}
  | ^(NEquals a=expression b=expression) {$value = helper.nEquals($a.value, $b.value);}
  | ^(LThan a=expression b=expression) {$value = helper.lessThan($a.value, $b.value);}
  | ^(GThan a=expression b=expression) {$value = helper.greaterThan($a.value, $b.value);}
  | ^(Add a=expression b=expression) {$value = helper.add($a.value, $b.value);}
  | ^(Subtract a=expression b=expression) {$value = helper.subtract($a.value, $b.value);}
  | ^(Multiply a=expression b=expression) {$value = helper.multiply($a.value, $b.value);}
  | ^(Divide a=expression b=expression) {$value = helper.divide($a.value, $b.value);}
  | ^(INDEX index=expression vector=expression) {$value = helper.index($vector.value, $index.value);}
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
