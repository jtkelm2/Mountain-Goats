package gadgets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;

class QueryRegion
{
	private var regions:Array<Region>;

	public function new()
	{
		regions = [];
	}

	public function addRegion(x:Float, y:Float, width:Int, height:Int):QueryRegion
	{
		regions.push(new Region(x, y, width, height));
		return this;
	}

	public function addRegionGrid(x:Float, y:Float, width:Int, height:Int, gridRows:Int, gridCols:Int):QueryRegion
	{
		var regionWidth = width / gridCols;
		var regionHeight = height / gridRows;
		for (i in 0...gridRows)
		{
			for (j in 0...gridCols)
			{
				addRegion(x + j * regionWidth, y + i * regionHeight, Std.int(regionWidth), Std.int(regionHeight));
			}
		}
		return this;
	}

	public function query(x:Null<Float> = null, y:Null<Float> = null):Null<Int>
	{
		for (i in 0...regions.length)
		{
			if (regions[i].query(x, y))
			{
				return i;
			}
		}
		return null;
	}

	public function toggleVisible(bool:Bool)
	{
		for (region in regions)
		{
			region.toggleVisible(bool);
		}
	}
}

class Region extends FlxSprite
{
	public function new(x:Float, y:Float, width:Int, height:Int)
	{
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		// makeGraphic(width, height, FlxColor.BLUE);
		// this.alpha = FlxG.random.int(2, 10) / 10;
	}

	public function query(x:Null<Float> = null, y:Null<Float> = null):Bool
	{
		var queryX:Float;
		var queryY:Float;
		if (x == null)
		{
			queryX = FlxG.mouse.x;
			queryY = FlxG.mouse.y;
		}
		else
		{
			queryX = x;
			queryY = y;
		}
		return (this.x <= queryX && queryX <= this.x + width && this.y <= queryY && queryY <= this.y + height);
	}

	public function toggleVisible(bool:Bool)
	{
		visible = bool;
	}
}
