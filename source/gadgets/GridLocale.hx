package gadgets;

import flixel.math.FlxPoint;
import system.Data;

class GridLocale extends Locale
{
	/*public var x:Float;
		public var y:Float;
		public var width:Int;
		public var height:Int; */
	public var gridCols:Int;
	public var gridRows:Int;
	public var startingCorner:Int;

	public function new(x:Float, y:Float, width:Float, height:Float, gridRows:Int, gridCols:Int, autoupdate:Bool = true, startingCorner:Int = 0)
	{
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.gridCols = gridCols;
		this.gridRows = gridRows;
		this.startingCorner = startingCorner;
		pieces = [for (_ in 0...gridCols * gridRows) null];
		this.autoupdate = autoupdate;
	}

	public function getPosition(slot:Int):FlxPoint
	{
		var col = (startingCorner % 2 == 0 ? 1 : -1) * (slot % gridCols);
		var row = (startingCorner < 2 ? 1 : -1) * Std.int(slot / gridCols);
		return FlxPoint.get(x + (col / gridCols) * width, y + (row / gridRows) * height);
	}

	public function updatePositions(callback:Null<Gamepiece->Void> = null)
	{
		if (autoupdate)
		{
			pieces = pieces.filter(piece -> (piece != null));
			for (_ in 0...gridCols * gridRows - pieces.length)
			{
				pieces.push(null);
			}
		}
		for (i in 0...pieces.length)
		{
			if (pieces[i] != null)
			{
				var newPos = getPosition(i);
				pieces[i].moveTo(newPos.x, newPos.y, callback);
				newPos.put();
			}
		}
	}
}
