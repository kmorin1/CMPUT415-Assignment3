tree grammar Interpreter;

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
  : Int {$tsym = (Type)currentScope.resolve("int");}
  | Vector {$tsym = (Type)currentScope.resolve("vector");}
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
  VariableSymbol vs = null;
  ArrayList<Integer> result = new ArrayList<Integer>(5);
  int domainSize = 0;
  int localMarker = input.mark();
  int index = 0;
}
@after {
  currentScope = currentScope.getEnclosingScope();
}
	: ^(Filter Identifier
	{
	   vs = new VariableSymbol($Identifier.text, (Type)currentScope.resolve("int"));
     currentScope.define(vs);
  }
  vector=expression
  {
    if ($vector.value instanceof ReturnInt)
    {
      throw new RuntimeException("Filter domain must be a vector");
    }
    
    ReturnVector domain = (ReturnVector)$vector.value;
    domainSize = domain.size();
    result = new ArrayList<Integer>(domain.size());
    localMarker = input.mark();
    if (index < domainSize)
    {
      vs.value = new ReturnInt(domain.value.get(index));
      index++;
    }
  }
  condition=expression
  {
    if ($condition.value != null && $condition.value instanceof ReturnVector)
    {
      throw new RuntimeException("Filter condition must be an integer");
    }
    
    if ($condition.value != null && !helper.equalsZero($condition.value)) {
      int toAdd = ((ReturnInt)vs.value).value;
      result.add(toAdd);
    }
    
    while (index < domainSize)
    {
      vs.value = new ReturnInt(domain.value.get(index));
      index++;
      input.LT(1);
      input.rewind(localMarker);
      ReturnInt returned = (ReturnInt)expression();
      if (!helper.equalsZero(returned)) {
        int toAdd = ((ReturnInt)vs.value).value;
        result.add(toAdd);
      }
    }
  }
  )
  {
    $value = new ReturnVector(result);
  }
  ;
  
generator returns [ReturnValue value]
@init {
  currentScope = new LocalScope(currentScope);
  VariableSymbol vs = null;
  ArrayList<Integer> result = new ArrayList<Integer>(5);
  int domainSize = 0;
  int localMarker = input.mark();
  int index = 0;
} 
@after {
  currentScope = currentScope.getEnclosingScope();
}
	: ^(GENERATOR Identifier 
	{
	  vs = new VariableSymbol($Identifier.text, (Type)currentScope.resolve("int"));
	  currentScope.define(vs);
	}
	vector=expression
	{
	  if ($vector.value instanceof ReturnInt)
	  {
	    throw new RuntimeException("Generator domain must be a vector");
	  }
	  
	  ReturnVector domain = (ReturnVector)$vector.value;
	  domainSize = domain.size();
	  result = new ArrayList<Integer>(domain.size());
	  localMarker = input.mark();
	  if (index < domainSize)
	  {
	    vs.value = new ReturnInt(domain.value.get(index));
	    index++;
	  }
	}
	apply=expression
	{
	
	  if ($apply.value instanceof ReturnVector)
	  {
	    throw new RuntimeException("Generator must generate integers");
	  }
	  
	  ReturnInt toAdd = (ReturnInt)$apply.value;
	  if (toAdd != null) {
	    result.add(toAdd.value);
	  }
	  
	  while (index < domainSize)
	  {
	    vs.value = new ReturnInt(domain.value.get(index));
	    index++;
	    input.LT(1);
	    input.rewind(localMarker);
	    ReturnInt returned = (ReturnInt)expression();
	    result.add(returned.value);
	  }
	}
	)
	{
	  $value = new ReturnVector(result);
	}
	;