package states;

// import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxTimer;
import gadgets.*;
import gameobjects.*;
import system.*;
import system.Data;

class Gameover implements Gamestate // extends FlxBasic
{
	var ps:PlayState;

	public var gamestateTag:Tag = GameoverGSTag;

	public function new(ps:PlayState)
	{
		// super();
		this.ps = ps;
		// ps.add(this);
	}

	public function refresh():Gamestate
	{
		System.mouse.setActive([]);
		return this;
	}

	public function handle(eventID:EventID)
	{
		switch eventID
		{
			case _:
		}
	}
}
