tree grammar Templater;

options {
  language = Java;
  output = template;
  tokenVocab = simpleCalc;
  ASTLabelType = CommonTree;
}

@header
{
  package scalc;
}
@members {
  List<String> variables = new ArrayList<String>();
  int branchCounter = 0;
}

program
  : a+=mainblock -> compose(final={$a})
  ;
  
mainblock
  : ^(MAINBLOCK (a+=varDecl)* (b+=statement)*) 
    -> assemblyOut(vars={variables}, assi={$a}, state={$b})
  ;

subblock
  : ^(SUBBLOCK (a+=statement)*) -> compose(final={$a})
  ;

varDecl
  : ^(DECLARATION a=Identifier b=expression) 
    {variables.add($a.text);}
    -> outputAssi(var={$a.text}, value={$b.st})
  ;
  
statement
  : a+=assignment -> compose(final={$a})
  | a+=printStatement ->compose(final={$a})
  | a+=ifStatement -> compose(final={$a})
  | a+=loopStatement -> compose(final={$a})
  ; 

assignment
  : ^(Assign a=Identifier b=expression) -> outputAssi(var={$a.text}, value={$b.st})
  ;
  
printStatement
  : ^(Print a+=expression) -> outputPrint(value={$a})
  ;
  
ifStatement
  : ^(If a=expression b=subblock) {branchCounter++;}
    -> outputIf(a={$a.st}, b={$b.st}, c={branchCounter})
  ;
  
loopStatement
  : ^(Loop a=expression b=subblock) {branchCounter+=2;}
  -> outputWhile(a={$a.st}, b={$b.st}, c={branchCounter},d={branchCounter-1})
  ;
  
expression
  : ^(Equals a=expression b=expression)  -> eExpr(a={$a.st}, b={$b.st})
  | ^(NEquals a=expression b=expression) -> neExpr(a={$a.st}, b={$b.st})
  | ^(LThan a=expression b=expression) -> ltExpr(a={$a.st}, b={$b.st})
  | ^(GThan a=expression b=expression) -> gtExpr(a={$a.st}, b={$b.st})
  | ^(Add a=expression b=expression) -> addExpr(a={$a.st}, b={$b.st})
  | ^(Subtract a=expression b=expression) -> subExpr(a={$a.st}, b={$b.st})
  | ^(Multiply a=expression b=expression) -> mulExpr(a={$a.st}, b={$b.st})
  | ^(Divide a=expression b=expression) -> divExpr(a={$a.st}, b={$b.st})
  | c=atom -> compose(final={$c.st})
  ;
  
atom
  : Number -> pushInt(num={$Number.text})
  | Identifier -> pushVar(var={$Identifier.text})
  ;
