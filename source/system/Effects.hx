package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import system.Data;
import system.System;

typedef EffectsProfile =
{
	transparing:Null<FlxTween>,
	moving:Null<FlxTween>
}

class Effects extends FlxBasic
{
	private var effectRegistry:Map<IDObject, EffectsProfile>;

	public function new()
	{
		super();
		effectRegistry = [];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	private function emptyProfile():EffectsProfile
	{
		return {transparing: null, moving: null};
	}

	public function registerObject(idObject:IDObject)
	{
		if (!effectRegistry.exists(idObject))
		{
			effectRegistry[idObject] = emptyProfile();
		}
	}

	public function toggleTransparing(idObject:IDObject, bool:Bool)
	{
		registerObject(idObject);

		if (effectRegistry[idObject].transparing != null)
		{
			effectRegistry[idObject].transparing.cancel();
		}
		idObject.alpha = 1;

		if (bool)
		{
			effectRegistry[idObject].transparing = FlxTween.tween(idObject, {alpha: 0.5}, 1, {type: PINGPONG});
		}
	}

	public function transpare(idObject:IDObject)
	{
		toggleTransparing(idObject, false);
		idObject.alpha = 0.5;
	}

	public function detranspare(idObject:IDObject)
	{
		toggleTransparing(idObject, false);
		idObject.alpha = 1;
	}

	public function fadeOut(idObject:IDObject)
	{
		toggleTransparing(idObject, false);
		idObject.alpha = 1;
		effectRegistry[idObject].transparing = FlxTween.tween(idObject, {alpha: 0}, 1);
	}

	public function fadeIn(idObject:IDObject)
	{
		toggleTransparing(idObject, false);
		idObject.alpha = 0;
		effectRegistry[idObject].transparing = FlxTween.tween(idObject, {alpha: 1}, 1);
	}

	public function quadMove(piece:Gamepiece, destX:Float, destY:Float, callback:Null<Gamepiece->Void>)
	{
		piece.isMoving = true;

		var distance:Float = Math.pow(piece.x - destX, 2) + Math.pow(piece.y - destY, 2);
		var duration = FlxMath.bound(distance / 10000, 0.01, Reg.maxMoveTime);

		var onComplete = _ ->
		{
			piece.isMoving = false;
			if (callback != null)
				callback(piece);
			else
				return;
		};

		FlxTween.tween(piece, {x: destX, y: destY}, duration, {ease: FlxEase.quadInOut, onComplete: onComplete});
	}

	public function instantMove(piece:Gamepiece, destX:Float, destY:Float, callback:Null<Gamepiece->Void>)
	{
		piece.x = destX;
		piece.y = destY;
		if (callback != null)
		{
			callback(piece);
		}
	}
}
