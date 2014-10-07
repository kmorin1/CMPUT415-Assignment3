tree grammar Templater;

options {
  language = Java;
  output = template;
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
  boolean conditional = true;
  
  public Templater(TreeNodeStream input, SymbolTable symtab) {
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
  }
  ;

assignment
  : ^(Assign Identifier expression)
  {
  }
  ;

printStatement
  : ^(Print expression)
  {
  }
  ;

ifStatement
@init {
  boolean localconditional = conditional;
}
  : ^(If expression subblock) 
  ;
  
loopStatement
@init {
  boolean localconditional = conditional;
  int localmarker = input.mark();
}
  : ^(Loop expression subblock) 
  ;

expression
  : ^(Equals expression expression)
  | ^(NEquals expression expression)
  | ^(LThan expression expression)
  | ^(GThan expression expression)
  | ^(Add expression expression)
  | ^(Subtract expression expression)
  | ^(Multiply expression expression)
  | ^(Divide expression expression)
  | ^(INDEX index=expression vector=expression)
  | ^(Range min=atom max=atom)
  | a=atom
  ;
  
atom
  : Number
  | Identifier
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
  }
  | filter
  | generator
  | ^(SUBEXPR expression)
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

  condition=expression

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

	apply=expression
	
	)

	;