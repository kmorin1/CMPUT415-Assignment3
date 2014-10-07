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
  int counter = 0;
  
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
  : mainblock -> return(a={$mainblock.st})
  ;
  
mainblock
  : ^(MAINBLOCK (d+=declaration)* (s+=statement)*) -> llvmProgram(declarations={$d}, statements={$s})
  ;

subblock
  : ^(SUBBLOCK (s+=statement)*) -> return(a={$s})
  ;

declaration
  : varDecl -> return(a={$varDecl.st})
  ;

statement
  : assignment -> return(a={$assignment.st})
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
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
  }
  -> declare(var={$Identifier.text}, expr={$expression.st}, name={$expression.name})
  ;

assignment
  : ^(Assign Identifier expression) -> return(a={$expression.st})
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
  : ^(Loop expression subblock) 
  ;

expression returns [String name]
@after {
	//counter++;
}
  : ^(Equals expression expression)
  | ^(NEquals expression expression)
  | ^(LThan expression expression)
  | ^(GThan expression expression)
  | ^(Add x=expression {counter++;}y=expression {counter++;}) {$name = Integer.toString(counter);}-> add(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(Subtract expression expression)
  | ^(Multiply expression expression)
  | ^(Divide expression expression)
  | ^(INDEX index=expression vector=expression)
  | ^(Range min=atom max=atom)
  | a=atom {$name = $a.name;}-> return(a={$a.st})
  ;
  
atom returns [String name]
@after {
	//$name = counter;
}
  : Number {$name = Integer.toString(counter);} -> load(name={counter}, value={$Number.text})
  | Identifier {$name = $Identifier.text;}
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
  }
  | filter
  | generator
  | ^(SUBEXPR expression) {$name = $expression.name;} -> return(a={$expression.st})
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