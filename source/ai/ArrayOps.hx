package ai;

using Lambda;

class ArrayOps
{
	public static function any(bs:Array<Bool>)
	{
		for (b in bs)
		{
			if (b)
			{
				return true;
			}
		}
		return false;
	}

	public static function all(bs:Array<Bool>)
	{
		for (b in bs)
		{
			if (!b)
			{
				return false;
			}
		}
		return true;
	}

	public static function isDescending(xs:Array<Int>)
	{
		for (i in 1...xs.length)
		{
			if (xs[i] > xs[i - 1])
			{
				return false;
			}
		}
		return true;
	}

	public static function isAscending(xs:Array<Int>)
	{
		for (i in 1...xs.length)
		{
			if (xs[i] < xs[i - 1])
			{
				return false;
			}
		}
		return true;
	}

	public static function minimum(xs:Array<Int>, ?start:Int = null)
	{
		var result = start;
		for (x in xs)
		{
			if (x < result)
			{
				result = x;
			}
		}
		return result;
	}

	public static function last<T>(xs:Array<T>)
	{
		return xs[xs.length - 1];
	}

	public static function pow<T>(xs:Array<T>, n:Int):Array<Array<T>>
	{
		if (n == 0)
		{
			return [[]];
		}
		return pow(xs, n - 1).map(ys -> [for (x in xs) ys.concat([x])]).flatten();
	}

	public static function sum(xs:Iterable<Int>)
	{
		return xs.fold((a, b) -> a + b, 0);
	}

	public static function equals(xs:Array<Int>, ys:Array<Int>)
	{
		if (xs.length != ys.length)
		{
			return false;
		}
		for (i in 0...xs.length)
		{
			if (xs[i] != ys[i])
			{
				return false;
			}
		}
		return true;
	}

	public static function nub<T>(xs:Array<T>, ?eq:(T, T) -> Bool = null):Array<T>
	{
		var eqOp = eq == null ?(a, b) -> a == b : eq;
		var result = [];
		for (x in xs)
		{
			var contains = false;
			for (y in result)
			{
				if (eqOp(x, y))
				{
					contains = true;
					break;
				}
			}
			if (!contains)
			{
				result.push(x);
			}
		}
		return result;
	}

	public static function zipWith<T, S, Q>(xs:Array<T>, ys:Array<S>, f:(T, S) -> Q):Array<Q>
	{
		var result = [];
		for (i in 0...xs.length)
		{
			result.push(f(xs[i], ys[i]));
		}
		return result;
	}

	public static function counts(xs:Array<Int>):Map<Int, Int>
	{
		var map = [for (mountain in 5...11) mountain => 0];
		for (x in xs)
		{
			if (x != 0)
			{
				map[x] += 1;
			}
		}
		return map;
	}

	public static function largestVia<T>(xs:Array<T>, f:T->Float):T
	{
		var leader = xs[0];
		var val = f(xs[0]);
		for (i in 1...xs.length)
		{
			var newVal = f(xs[i]);
			if (newVal >= val)
			{
				leader = xs[i];
				val = newVal;
			}
		}
		return leader;
	}
}
