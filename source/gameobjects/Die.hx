package gameobjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gadgets.*;
import system.*;
import system.Data;

class Die implements Gamepiece extends FlxSprite
{
	public var inLocale:Null<Locale> = null;
	public var value:Int;
	public var slot:Int;
	public var isWild:Bool;

	public var isMoving:Bool;

	private var rollTimer:Float;

	public var currentlyRolling:Bool;

	public var teleportMode:Bool;

	public function new()
	{
		super();
		loadGraphic("assets/die.png", true, Reg.DIE_SIZE, Reg.DIE_SIZE);
		roll();
		currentlyRolling = false;
		teleportMode = true;
		isMoving = false;
		System.mouse.initClickable(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (currentlyRolling)
		{
			rollTimer -= elapsed;
			if (rollTimer < 0)
			{
				roll(true);
				rollTimer += 0.2;
			}
		}
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
		return DieID(this);
	}

	public function roll(fakeRoll:Bool = false):Int
	{
		var newValue = FlxG.random.int(1, 6);
		if (fakeRoll && newValue == value)
		{
			newValue = newValue % 6 + 1;
		}
		value = newValue;
		animation.frameIndex = value - 1;
		isWild = value == 1;
		return value;
	}

	public function startRolling()
	{
		rollTimer = 0.2;
		currentlyRolling = true;
	}

	public function stopRolling(diceBox:DiceBox, slot:Int, callback:Null<Gamepiece->Void> = null)
	{
		var curY = y;
		var onComplete = _ ->
		{
			currentlyRolling = false;
			new FlxTimer().start(1.5, _ ->
			{
				diceBox.toSlot(slot, this, callback);
			});
		}
		FlxTween.tween(this, {"scale.x": 1.8, "scale.y": 1.8, y: curY - Reg.DIE_SIZE * 2}, 0.3)
			.then(FlxTween.tween(this, {"scale.x": 1, "scale.y": 1, y: curY}, 0.5, {ease: FlxEase.expoIn, onComplete: onComplete}));
	}

	public function changeWild(delta:Int, diceBox:DiceBox):Bool
	{
		if (isWild && (value == 1 && diceBox.oneCount > 1 || value != 1))
		{
			value = FlxMath.maxAdd(value, delta, 6, 1);
			animation.frameIndex = value == 1 ? value - 1 : value + 5;
			diceBox.updateSlotValues();
			return true;
		}
		return false;
	}

	public function toggleReserve(bool:Bool)
	{
		System.effects.toggleTransparing(this, bool);
	}
}
