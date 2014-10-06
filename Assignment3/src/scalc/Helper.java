package scalc;

import java.util.ArrayList;

public class Helper {
	
	
	public Helper() {
		
	}
	
	public ReturnVector range(ReturnValue minValue, ReturnValue maxValue) {
		System.out.println("Doing range operation!");
		ReturnInt min = minValue instanceof ReturnInt ? (ReturnInt)minValue : null;
		ReturnInt max = maxValue instanceof ReturnInt ? (ReturnInt)maxValue : null;
		if (min != null && max != null) {
			
			if (min.value > max.value) {
				throw new RuntimeException("Range operation must be non-decreasing: " + min.value + ".." + max.value);
			}
			
			ArrayList<Integer> result = new ArrayList<Integer>(max.value - min.value + 1);
			for (int i = min.value; i <= max.value; i++) {
				result.add(i);
			}
			return new ReturnVector(result);
		}
		else {
			throw new RuntimeException("Failed range operation!");
		}
	}
	
	public ReturnValue equals(ReturnValue a, ReturnValue b) {
		System.out.println("Checking if equals!");
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			System.out.println("Both integers!");
			int equal = 0;
			if (inta.value == intb.value) {
				equal = 1;
			}
			return new ReturnInt(equal);
		}
		else if (vecta != null && vectb != null) {
			int minSize = vecta.size() > vectb.size() ? vectb.size() : vecta.size();
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> result = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < minSize; i++) {
				int value1 = vecta.value.get(i);
				int value2 = vectb.value.get(i);
				int compared = value1 == value2 ? 1 : 0;
				result.add(compared);
			}
			
			for (int i = 0; i < maxSize - minSize; i++) {
				result.add(0);
			}
			
			return new ReturnVector(result);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.equals(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.equals(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed checking equals!");
		}
	}
}
