package scalc;

public class VariableSymbol extends Symbol {
	public ReturnValue value;
	
	public VariableSymbol(String name, Type type)
	{
		super(name, type);
	}
}
