package gameobjects;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gadgets.*;
import system.*;
import system.Data;

class Goat implements Gamepiece extends FlxSprite
{
	public var inLocale:Locale;
	public var square:Square;
	public var player:Int;

	public var teleportMode:Bool;
	public var isMoving:Bool;

	public function new(player:Int, square:Square)
	{
		super();
		loadGraphic("assets/goat.png", true, Reg.GOAT_SIZE, Reg.GOAT_SIZE);
		animation.frameIndex = player;
		this.player = player;

		scale.x = 2;
		scale.y = 2;

		teleportMode = true;
		square.add(this);
		teleportMode = false;
		isMoving = false;

		System.mouse.initClickable(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function moveTo(x:Float, y:Float, callback:Null<Gamepiece->Void> = null)
	{
		if (teleportMode)
		{
			System.effects.instantMove(this, x, y, callback);
		}
		else
		{
			System.effects.quadMove(this, x, y, callback);
		}
	}

	public function id()
	{
		return GoatID(this);
	}

	public function togglePreview(bool:Bool)
	{
		System.effects.toggleTransparing(this, bool);
	}
}
