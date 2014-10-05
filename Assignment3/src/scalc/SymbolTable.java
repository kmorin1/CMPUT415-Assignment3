package scalc;

public class SymbolTable {
	GlobalScope globals = new GlobalScope();
	
	public SymbolTable()
	{
		initTypeSystem();
	}
	
	protected void initTypeSystem()
	{
		globals.define(new BuiltInTypeSymbol("int"));
		globals.define(new BuiltInTypeSymbol("vector"));
	}
}
