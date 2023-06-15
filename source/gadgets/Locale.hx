package gadgets;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import system.*;
import system.Data;

abstract class Locale extends FlxObject
{
	private var pieces:Array<Null<Gamepiece>>;

	private var autoupdate:Bool;

	abstract public function getPosition(slot:Int):FlxPoint;

	abstract public function updatePositions(callback:Null<Gamepiece->Void> = null):Void;

	/* public function instantAdd(piece:Gamepiece):Null<Int>
		{
			for (i in 0...pieces.length)
			{
				if (pieces[i] == null)
				{
					var dest = getPosition(i);
					piece.x = dest.x;
					piece.y = dest.y;
					dest.put();
					return i;
				}
			}
			return null;
	}*/
	public function add(piece:Gamepiece, callback:Null<Gamepiece->Void> = null):Null<Int>
	{
		if (!pieces.contains(piece))
		{
			for (i in 0...pieces.length)
			{
				if (pieces[i] == null)
				{
					return insert(piece, i, callback);
				}
			}
		}
		else
		{
			var newCallback = null;
			if (callback != null)
			{
				newCallback = otherPiece ->
				{
					if (otherPiece == piece)
					{
						callback(piece);
					}
				}
			}
			updatePositions(newCallback);
		}
		return null;
	}

	public function insert(piece:Gamepiece, i:Int, callback:Null<Gamepiece->Void> = null):Null<Int>
	{
		if (!pieces.contains(null))
		{
			return null;
		}

		if (piece.inLocale != null)
		{
			piece.inLocale.remove(piece);
		}
		piece.inLocale = this;

		var newCallback = null;
		if (callback != null)
		{
			newCallback = otherPiece ->
			{
				if (otherPiece == piece)
				{
					callback(piece);
				}
			}
		}

		if (pieces[i] == null)
		{
			pieces[i] = piece;
			if (!autoupdate)
			{
				var pos = getPosition(i);
				piece.moveTo(pos.x, pos.y, callback);
				pos.put();
				return i;
			}
		}
		else
		{
			pieces.insert(i, piece);
			pieces.remove(null);
		}

		updatePositions(newCallback);
		return i;
	}

	public function vacate(slot:Int, callback:Null<Gamepiece->Void> = null):Gamepiece
	{
		var vacated = pieces[slot];
		pieces[slot] = null;
		if (autoupdate)
		{
			updatePositions(callback);
		}
		return vacated;
	}

	public function remove(gamepiece:Gamepiece, callback:Null<Gamepiece->Void> = null):Null<Int>
	{
		for (i in 0...pieces.length)
		{
			if (pieces[i] == gamepiece)
			{
				vacate(i, callback);
				return i;
			}
		}
		return null;
	}

	public function getSlot(gamepiece:Gamepiece):Null<Int>
	{
		var result = pieces.indexOf(gamepiece);
		if (result == -1)
		{
			return null;
		}
		return result;
	}

	/* public function lastFilledSlot():Null<Int> {
		var result = null;
		for (i in 0...pieces.length) {
			if (pieces[i] != null) {
				result = i;
			}
		}
		return i;
	}*/
	override private function set_x(newX:Float)
	{
		if (pieces != null)
		{
			for (piece in pieces)
			{
				if (piece != null)
				{
					piece.x += newX - x;
				}
			}
		}
		return super.set_x(newX);
	}

	override private function set_y(newY:Float)
	{
		if (pieces != null)
		{
			for (piece in pieces)
			{
				if (piece != null)
				{
					piece.y += newY - y;
				}
			}
		}
		return super.set_y(newY);
	}

	override private function set_angle(newAngle:Float)
	{
		if (pieces != null)
		{
			var localeMidpoint = getMidpoint();
			var angleDiff = newAngle - angle;
			for (piece in pieces)
			{
				if (piece != null)
				{
					var oldMidpoint = FlxPoint.get(piece.x + piece.origin.x, piece.y + piece.origin.y);
					var newMidpoint = FlxPoint.get(piece.x + piece.origin.x, piece.y + piece.origin.y);
					newMidpoint.pivotDegrees(localeMidpoint, angleDiff);
					piece.x += newMidpoint.x - oldMidpoint.x;
					piece.y += newMidpoint.y - oldMidpoint.y;
					piece.angle += angleDiff;
					oldMidpoint.put();
					newMidpoint.put();
				}
			}

			localeMidpoint.put();
		}
		return super.set_angle(newAngle);
	}
}
