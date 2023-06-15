package gadgets;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class RotationAnchor
{
	private var anchoredObjects:Array<FlxObject>;

	public var angle(default, set):Float;
	public var x(default, set):Float;
	public var y(default, set):Float;

	public function new(x:Float = 0, y:Float = 0)
	{
		this.anchoredObjects = [];
		this.x = x;
		this.y = y;
		angle = 0;
	}

	public function add(object:FlxObject)
	{
		anchoredObjects.push(object);
	}

	private function rotateObject(object:FlxObject, angleDiff:Float)
	{
		var oldMidpoint = object.getMidpoint();
		var newMidpoint = object.getMidpoint();
		var anchorPoint = FlxPoint.get(x, y);
		newMidpoint.pivotDegrees(anchorPoint, angleDiff);
		object.x += newMidpoint.x - oldMidpoint.x;
		object.y += newMidpoint.y - oldMidpoint.y;
		object.angle += angleDiff;
		oldMidpoint.put();
		newMidpoint.put();
		anchorPoint.put();

		/* var oldMidpoint = object.getMidpoint();
			var relX = oldMidpoint.x - x;
			var relY = oldMidpoint.y - y;
			var angleDiffRad = angleDiff * 0.01745;
			var newRelX = relX * FlxMath.fastCos(angleDiffRad) - relY * FlxMath.fastSin(angleDiffRad);
			var newRelY = relX * FlxMath.fastSin(angleDiffRad) + relY * FlxMath.fastCos(angleDiffRad);
			object.x += newRelX - relX;
			object.y += newRelY - relY;
			object.angle += angleDiff; */
	}

	private function set_x(newX:Float)
	{
		if (x == null)
		{
			x = newX;
			return x;
		}
		var diffX = newX - x;
		for (object in anchoredObjects)
		{
			object.x += diffX;
		}
		x = newX;
		return x;
	}

	private function set_y(newY:Float)
	{
		if (y == null)
		{
			y = newY;
			return y;
		}
		var diffY = newY - y;
		for (object in anchoredObjects)
		{
			object.y += diffY;
		}
		y = newY;
		return y;
	}

	private function set_angle(newAngle:Float)
	{
		if (angle == null)
		{
			angle = newAngle;
			return angle;
		}
		var angleDiff = newAngle - angle;
		for (object in anchoredObjects)
		{
			rotateObject(object, angleDiff);
		}
		angle = newAngle;
		return angle;
	}
}
