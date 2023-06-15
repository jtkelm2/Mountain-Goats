package gameobjects;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gadgets.*;
import system.*;
import system.Data;

class MoveConfirmButton implements IDObject extends FlxButton
{
	public function new(x, y, text, callback)
	{
		super(x, y, text, callback);
		loadGraphic("assets/moveconfirm.png", true, Reg.MOVE_CONFIRM_WIDTH, Reg.MOVE_CONFIRM_HEIGHT);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function id()
	{
		return MoveConfirmButtonID(this);
	}
}
