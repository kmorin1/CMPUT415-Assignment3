package vcalc;

import java.util.ArrayList;

public class ReturnInt extends ReturnValue {
	int value;
	
	public ReturnInt(int v) {
		this.value = v;
	}
	
	@Override
	public Object getValue() {
		return this.value;
	}
	
	@Override
	public String toString() {
		return Integer.toString(this.value);
	}
	
	public ReturnVector promote(int size) {
		ArrayList<Integer> vector = new ArrayList<Integer>(size);
		
		for (int i = 0; i < size; i++) {
			vector.add(this.value);
		}
		
		return new ReturnVector(vector);
	}
}
