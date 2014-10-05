package scalc;

public class Symbol {
	String name;
	Type type;
	Scope scope;
	
	public Symbol(String name) { this.name = name; }
    public Symbol(String name, Type type) { this(name); this.type = type; }
    public String getName() { return name; }

    public String toString() {
        String s = "";
        if ( scope!=null ) s = scope.getScopeName()+".";
        if ( type!=null ) return '<'+s+getName()+":"+type+'>';
        return s+getName();
    }
}
