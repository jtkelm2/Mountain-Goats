package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import system.Data;
import system.System;

class Dragger extends FlxBasic
{
	public var dragged(default, set):Null<IDObject>;

	public function new()
	{
		super();
		dragged = null;
	}

	override public function update(elapsed:Float)
	{
		if (dragged != null)
		{
			dragged.x += FlxG.mouse.deltaScreenX;
			dragged.y += FlxG.mouse.deltaScreenY;
			if (FlxG.mouse.justReleased)
			{
				dragged = null;
			}
		}
	}

	private function set_dragged(newDragged:Null<IDObject>)
	{
		if (newDragged != null)
		{
			dragged = newDragged;
			dragged.x += FlxG.mouse.screenX - (dragged.x + dragged.origin.x);
			dragged.y += FlxG.mouse.screenY - (dragged.y + dragged.origin.y);
			System.effects.transpare(dragged);
			return dragged;
		}
		else
		{
			if (dragged != null)
			{
				System.effects.detranspare(dragged);
				System.events.handle(DraggerDropped(dragged.id()));
				dragged = null;
			}
			return null;
		}
	}
}
