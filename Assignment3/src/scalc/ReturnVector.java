package scalc;

import java.util.ArrayList;

public class ReturnVector extends ReturnValue {
	ArrayList<Integer> value = new ArrayList<Integer>(1);
	
	public ReturnVector(ArrayList<Integer> v) {
		this.value = v;
	}
	
	public int size() {
		return this.value.size();
	}
	
	@Override
	public Object getValue() {
		return this.value;
	}
	
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(this.value.size() * 2 + 4);
		sb.append("[ ");
		for (int i : this.value) {
			sb.append(i + " ");
		}
		sb.append("]");
		return sb.toString();
	}
}
