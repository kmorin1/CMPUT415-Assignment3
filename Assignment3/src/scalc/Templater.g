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
  List<String> variables = new ArrayList<String>();
  
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
  : ^(MAINBLOCK (d+=declaration)* (s+=statement)*) -> llvmProgram(declarations={variables}, assignments={$d}, statements={$s})
  ;

subblock
  : ^(SUBBLOCK (s+=statement)*) -> return(a={$s})
  ;

declaration
  : varDecl -> return(a={$varDecl.st})
  ;

statement
  : assignment -> return(a={$assignment.st})
  | printStatement -> return(a={$printStatement.st})
  | ifStatement -> return(a={$ifStatement.st})
  | loopStatement -> return(a={$loopStatement.st})
  ;

type returns [Type tsym]
  : Int {$tsym = (Type)currentScope.resolve("int");}
  | Vector {$tsym = (Type)currentScope.resolve("vector");}
  ;
  
varDecl
  : ^(DECLARATION type Identifier expression)
  {
  	variables.add($Identifier.text);
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
  }
  -> outputAssi(var={$Identifier.text}, expr={$expression.st}, name={$expression.name})
  ;

assignment
  : ^(Assign Identifier expression) -> outputAssi(var={$Identifier.text}, expr={$expression.st}, name={$expression.name})
  ;

printStatement
  : ^(Print expression)
  {
  }
  -> print(expr={$expression.st}, result={$expression.name})
  ;

ifStatement
@init {
  boolean localconditional = conditional;
}
  : ^(If expression subblock) -> conditional(condition={$expression.st}, body={$subblock.st}, name={$expression.name})
  ;
  
loopStatement
  : ^(Loop expression subblock) -> loop(condition={$expression.st}, body={$subblock.st}, name={$expression.name})
  ;

expression returns [String name]
@after {
	//counter++;
}
  : ^(Equals x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> equals(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(NEquals x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> nEquals(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(LThan x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> lessThan(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(GThan x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> greaterThan(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter}) 
  | ^(Add x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> add(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(Subtract x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> sub(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(Multiply x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> mul(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(Divide x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> div(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(INDEX index=expression {counter++;} vector=expression {counter++;}) {$name = Integer.toString(counter);}-> index(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | ^(Range x=expression {counter++;} y=expression {counter++;}) {$name = Integer.toString(counter);}-> range(expr1={$x.st}, expr2={$y.st}, name1={$x.name}, name2={$y.name}, result={counter})
  | a=atom {$name = $a.name; counter++;}-> return(a={$a.st})
  ;
  
atom returns [String name]
@init {
	counter++;
}
@after {
	//$name = counter;
}
  : Number {$name = Integer.toString(counter);} -> load_num(name={counter}, value={$Number.text})
  | Identifier {$name = Integer.toString(counter);}
  {
    VariableSymbol vs = (VariableSymbol)currentScope.resolve($Identifier.text);
  }
  -> load_var(name={counter}, var={$Identifier.text})
  | filter {$name = $filter.name;} -> return(a={$filter.st})
  | generator {$name = $generator.name;} -> return(a={$generator.st})
  | ^(SUBEXPR expression) {$name = $expression.name;} -> return(a={$expression.st})
  ;
  
filter returns [String name]
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
  vector=expression {counter++;}

  condition=expression {counter++;}
  {$name = $condition.name;}
  ) -> returnTwo(a={$vector.st}, b={$condition.st})
  ;
  
generator returns [String name]
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
	vector=expression {counter++;}

	apply=expression {counter++;}
	{$name = $apply.name;}
	) -> returnTwo(a={$vector.st}, b={$apply.st})

	;