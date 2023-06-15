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

class Token implements Gamepiece extends FlxSprite
{
	public var inLocale:Locale;
	public var tokenType:TokenType;
	public var startingX:Float;
	public var startingY:Float;
	public var awarded:Bool;

	public var isMoving:Bool;

	public var teleportMode:Bool;

	public function new(x, y, tokenType:TokenType)
	{
		super(x, y);
		startingX = x;
		startingY = y;
		awarded = false;
		isMoving = false;
		teleportMode = true;

		switch tokenType
		{
			case MountainToken(n):
				var color = FlxColor.fromHSL(180, n / 10, 0.5);
				loadGraphic("assets/token.png", true, Reg.TOKEN_SIZE, Reg.TOKEN_SIZE);
				animation.frameIndex = n - 5;
			case BonusToken(n):
				loadGraphic("assets/bonustoken.png", true, Reg.TOKEN_SIZE * 2, Reg.TOKEN_SIZE);
				animation.frameIndex = Math.round((n - 6) / 3);
		}
		this.tokenType = tokenType;

		System.mouse.initClickable(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function id()
	{
		return TokenID(this);
	}

	public function moveTo(x, y, callback:Null<Gamepiece->Void> = null)
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

	public function togglePreview(bool:Bool)
	{
		System.effects.toggleTransparing(this, bool);
	}

	/* public function award(scoreboard:Scoreboard)
		{
			switch tokenType
			{
				case MountainToken(n):
					scoreboard.tokenLocales[mountain].add(this);
					togglePreview(false);
				case BonusToken(n):
					return;
			}

			var n = value();
				var destX = Reg.centerX - Reg.PANEL_WIDTH / 2 + (n - 5) * Reg.TOKEN_SIZE;
				var destY = Reg.centerY + Reg.nonUIHeight / 2;
				var callback = _ ->
				{
					scoreboard.award(tokenType);
					kill();
				}
				inLocale.remove(this);
				moveTo(destX, destY, callback);
			scoreboard.award(tokenType);
			awarded = true;
	}*/
	public function value()
	{
		switch tokenType
		{
			case MountainToken(n):
				return n;
			case BonusToken(n):
				return n;
		}
	}
}
