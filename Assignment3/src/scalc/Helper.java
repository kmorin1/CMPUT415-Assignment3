package scalc;

import java.util.ArrayList;

public class Helper {
	
	
	public Helper() {
		
	}
	
	public boolean equalsZero(ReturnValue value) {
		ReturnInt intValue = value instanceof ReturnInt ? (ReturnInt)value : null;
		if (intValue == null) {
			throw new RuntimeException("Expression in conditional must return an integer");
		}
		boolean result = intValue.value == 0;
		return result;
	}
	
	public ReturnVector range(ReturnValue minValue, ReturnValue maxValue) {
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
			throw new RuntimeException("Range operation requires two integers!");
		}
	}
	
	public ReturnValue equals(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = 0;
			if (inta.value == intb.value) {
				result = 1;
			}
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int minSize = vecta.size() > vectb.size() ? vectb.size() : vecta.size();
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < minSize; i++) {
				int value1 = vecta.value.get(i);
				int value2 = vectb.value.get(i);
				int result = value1 == value2 ? 1 : 0;
				vector.add(result);
			}
			
			for (int i = 0; i < maxSize - minSize; i++) {
				vector.add(0);
			}
			
			return new ReturnVector(vector);
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
	
	public ReturnValue nEquals(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = 0;
			if (inta.value != intb.value) {
				result = 1;
			}
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int minSize = vecta.size() > vectb.size() ? vectb.size() : vecta.size();
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < minSize; i++) {
				int value1 = vecta.value.get(i);
				int value2 = vectb.value.get(i);
				int result = value1 != value2 ? 1 : 0;
				vector.add(result);
			}
			
			for (int i = 0; i < maxSize - minSize; i++) {
				vector.add(0);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.nEquals(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.nEquals(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed checking not equals!");
		}
	}
	
	public ReturnValue lessThan(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = 0;
			if (inta.value < intb.value) {
				result = 1;
			}
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 0;
				int result = value1 < value2 ? 1 : 0;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.lessThan(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.lessThan(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed less than!");
		}
	}
	
	public ReturnValue greaterThan(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = 0;
			if (inta.value > intb.value) {
				result = 1;
			}
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 0;
				int result = value1 > value2 ? 1 : 0;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.greaterThan(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.greaterThan(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed greater than!");
		}
	}
	
	public ReturnValue add(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = inta.value + intb.value;
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 0;
				int result = value1 + value2;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.add(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.add(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed addition!");
		}
	}
	
	public ReturnValue subtract(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = inta.value - intb.value;
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 0;
				int result = value1 - value2;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.subtract(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.subtract(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed subtraction!");
		}
	}
	
	public ReturnValue multiply(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			int result = inta.value * intb.value;
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 0;
				int result = value1 * value2;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.multiply(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.multiply(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed multiplication!");
		}
	}
	
	public ReturnValue divide(ReturnValue a, ReturnValue b) {
		ReturnInt inta = a instanceof ReturnInt ? (ReturnInt)a : null;
		ReturnInt intb = b instanceof ReturnInt ? (ReturnInt)b : null;
		ReturnVector vecta = a instanceof ReturnVector ? (ReturnVector)a : null;
		ReturnVector vectb = b instanceof ReturnVector ? (ReturnVector)b : null;
		if (inta != null && intb != null) {
			if (intb.value == 0) {
				throw new RuntimeException("Trying to divide by 0!");
			}
			
			int result = inta.value / intb.value;
			return new ReturnInt(result);
		}
		else if (vecta != null && vectb != null) {
			int maxSize = vecta.size() > vectb.size() ? vecta.size() : vectb.size();
			ArrayList<Integer> vector = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int value1 = vecta.size() > i ? vecta.value.get(i) : 0;
				int value2 = vectb.size() > i ? vectb.value.get(i) : 1;
				int result = value1 / value2;
				vector.add(result);
			}
			
			return new ReturnVector(vector);
		}
		else if (inta != null && vectb != null)
		{
			ReturnVector promoted = inta.promote(vectb.value.size());
			return this.divide(promoted, b);
		}
		else if (vecta != null && intb != null) {
			ReturnVector promoted = intb.promote(vecta.value.size());
			return this.divide(vecta, promoted);
		}
		else {
			throw new RuntimeException("Failed division!");
		}
	}
	
	public ReturnValue index(ReturnValue vect, ReturnValue ind) {
		ReturnInt intIndex = ind instanceof ReturnInt ? (ReturnInt)ind : null;
		ReturnInt intVector = vect instanceof ReturnInt ? (ReturnInt)vect : null;
		ReturnVector vectIndex = ind instanceof ReturnVector ? (ReturnVector)ind : null;
		ReturnVector vector = vect instanceof ReturnVector ? (ReturnVector)vect : null;
		if (intVector != null) {
			throw new RuntimeException("Cannot index an integer!");
		}
		else if (vector != null && intIndex != null) {
			if (intIndex.value < 0 || intIndex.value >= vector.size()) {
				return new ReturnInt(0);
			}
			else {
				return new ReturnInt(vector.value.get(intIndex.value));
			}
		}
		else if (vector != null && vectIndex != null) {
			int maxSize = vector.size() > vectIndex.size() ? vector.size() : vectIndex.size();
			ArrayList<Integer> result = new ArrayList<Integer>(maxSize);
			for (int i = 0; i < maxSize; i++) {
				int index = vectIndex.size() > i ? vectIndex.value.get(i) : -1;
				ReturnInt item = (ReturnInt)this.index(vector, new ReturnInt(index));
				result.add(item.value);
			}
			
			return new ReturnVector(result);
		}
		else {
			throw new RuntimeException("Failed index!");
		}
	}
}
