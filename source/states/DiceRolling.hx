package states;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.*;
import flixel.util.FlxTimer;
import gadgets.*;
import gameobjects.*;
import system.*;
import system.Data;

class DiceRolling implements Gamestate // extends FlxBasic
{
	var ps:PlayState;
	var pauseInput:Bool;
	var rollingLocale:Locale;

	var diceRoller:FlxSprite;

	public var gamestateTag:Tag = DiceRollingGSTag;

	public function new(ps:PlayState)
	{
		// super();
		this.ps = ps;
		// ps.add(this);
		pauseInput = true;
		rollingLocale = new GridLocale(FlxG.width / 2 - 3 * Reg.DIE_SIZE, FlxG.height / 2 - Reg.DIE_SIZE, 8 * Reg.DIE_SIZE, 2 * Reg.DIE_SIZE, 1, 4, false);

		diceRoller = ps.diceRoller;
		diceRoller.x = -FlxG.width;
		diceRoller.y = FlxG.height / 2 - Reg.DIE_SIZE - Reg.SPACING;
	}

	public function refresh():Gamestate
	{
		System.mouse.setActive([]);
		pauseInput = true;
		trayIn();
		new FlxTimer().start(1, _ ->
		{
			startRolling();
		});
		return this;
	}

	public function handle(eventID:EventID)
	{
		switch eventID
		{
			case MouseClicked:
				if (!pauseInput)
				{
					stopRolling();
					pauseInput = true;
				}
			case SwitchState(gamestate):
				System.events.switchState(gamestate, true);
			case _:
		}
	}

	private function startRolling()
	{
		var t:Int = 0;
		for (die in ps.diceBox.dice)
		{
			die.startRolling();
			var callback:Null<Gamepiece->Void> = null;
			if (t == 3)
			{
				callback = _ ->
				{
					pauseInput = false;
					System.promptAI(this);
				};
			}
			new FlxTimer().start(t * Reg.maxMoveTime * 0.5, _ ->
			{
				rollingLocale.add(die, callback);
			});
			t += 1;
		}
	}

	private function stopRolling()
	{
		var t:Int = 0;
		for (die in ps.diceBox.dice)
		{
			var callback:Null<Gamepiece->Void> = null;
			if (t == 3)
			{
				callback = _ ->
				{
					System.events.handle(SwitchState(System.events.planning));
				};
			}
			var localT = t;
			new FlxTimer().start(localT / 5, _ ->
			{
				die.stopRolling(ps.diceBox, localT, callback);
			});
			t += 1;
		}
		new FlxTimer().start(3, _ ->
		{
			trayOut();
		});
	}

	private function trayIn()
	{
		FlxTween.tween(diceRoller, {x: FlxG.width / 2 - 3 * Reg.DIE_SIZE - Reg.SPACING}, 1, {ease: FlxEase.quadInOut});
	}

	private function trayOut()
	{
		FlxTween.tween(diceRoller, {x: 2 * FlxG.width}, 1, {
			ease: FlxEase.quadInOut,
			onComplete: _ ->
			{
				diceRoller.x = -FlxG.width;
			}
		});
	}
}
