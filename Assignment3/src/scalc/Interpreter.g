tree grammar Interpreter;

options {
  language = Java;
  tokenVocab = simpleCalc;
  ASTLabelType = CommonTree;
}

@header {
  package scalc;
  import java.util.HashMap;
  import java.util.ArrayList;
}

@members {
  HashMap memory = new HashMap();
  boolean conditional = true;
}

program
  : mainblock
  ;
  
mainblock
  : ^(MAINBLOCK varDecl* statement*)
  ;

subblock
  : ^(SUBBLOCK statement*)
  ;

varDecl
  : ^(DECLARATION Identifier expression) 
    {memory.put($Identifier.text, new Integer($expression.value));}
  ;
  
statement
  : assignment
  | printStatement
  | ifStatement
  | loopStatement
  ; 

assignment
  : ^(Assign Identifier expression) 
    {if (conditional) memory.put($Identifier.text, new Integer($expression.value));}
  ;
  
printStatement
  : ^(Print expression) 
    {if (conditional) System.out.println($expression.value);}
  ;
  
ifStatement
@init {
  boolean localconditional = conditional;
}
  : ^(If expression {if ($expression.value == 0) {conditional = false;}} subblock) 
     {conditional = localconditional;} 
  ;
  
loopStatement
@init {
  boolean localconditional = conditional;
  int localmarker = input.mark();
}
  : ^(Loop expression {if ($expression.value == 0) {conditional = false;}} subblock) 
     {if (conditional) input.rewind(localmarker);} 
     {conditional = localconditional;}
  ;
  
expression returns [int value]
  : ^(Equals a=expression b=expression) {if ($a.value == $b.value) {$value = 1;}
                                     else {$value = 0;}}
  | ^(NEquals a=expression b=expression) {if ($a.value != $b.value) {$value = 1;}
                                      else {$value = 0;}}
  | ^(LThan a=expression b=expression) {if ($a.value < $b.value) {$value = 1;}
                                    else {$value = 0;}}
  | ^(GThan a=expression b=expression) {if ($a.value > $b.value) {$value = 1;}
                                        else {$value = 0;}}
  | ^(Add a=expression b=expression) {$value = $a.value+$b.value;}
  | ^(Subtract a=expression b=expression) {$value = $a.value-$b.value;}
  | ^(Multiply a=expression b=expression) {$value = $a.value*$b.value;}
  | ^(Divide a=expression b=expression) {$value = $a.value/$b.value;}
  | a=atom {$value = $a.value;}
  ;
  
atom returns [int value]
  : Number {$value = Integer.parseInt($Number.text);}
  | Identifier
    {
      Integer v = (Integer)memory.get($Identifier.text);
      if ( v!=null ) $value = v.intValue();
      else System.err.println("undefined variable "+$Identifier.text);
    }
  ;
