package gameobjects;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gadgets.*;
import system.*;
import system.Data;

class Square implements IDObject extends FlxSprite
{
	private var hasLocale:Locale;

	public var squareType:SquareType;
	public var mountain:Int;
	public var mountainHeight:Int;

	private var freeTokenLocale:Locale;
	private var previewedTokenLocale:Locale;

	public var tokens:Array<Token>;
	public var previewedTokens:Array<Token>;

	public function new(x, y, squareType:SquareType, mountain:Int, mountainHeight:Int)
	{
		super(x, y);
		this.squareType = squareType;
		this.mountain = mountain;
		this.mountainHeight = mountainHeight;

		var localeSpacing = 2 * Reg.SPACING;
		switch squareType
		{
			case Mountaintop:
				hasLocale = new GridLocale(x + Reg.SQUARE_SIZE / 2 - Reg.GOAT_SIZE / 2, y + Reg.SQUARE_SIZE / 2 - Reg.GOAT_SIZE / 2, 3 * Reg.GOAT_SIZE, 0, 1,
					2);
				initTokens();
			case Mountain:
				var distBetweenGoats = Reg.SQUARE_SIZE - 2 * localeSpacing - Reg.GOAT_SIZE;
				hasLocale = new GridLocale(x + localeSpacing, y + localeSpacing, 2 * distBetweenGoats, 2 * distBetweenGoats, 2, 2);
			case MountainFoot:
				var distBetweenGoats = Reg.SQUARE_SIZE - 2 * localeSpacing - Reg.GOAT_SIZE;
				hasLocale = new GridLocale(x + localeSpacing, y + localeSpacing, 2 * distBetweenGoats, 2 * distBetweenGoats, 2, 2);
		}
		loadGraphic("assets/square.png", true, Reg.SQUARE_SIZE, Reg.SQUARE_SIZE);

		switch mountain
		{
			case 5:
				animation.frameIndex = (4 - mountainHeight) * 6;
			case 6:
				animation.frameIndex = (4 - mountainHeight) * 6 + 1;
			case 7:
				animation.frameIndex = (3 - mountainHeight) * 6 + 2;
			case 8:
				animation.frameIndex = (3 - mountainHeight) * 6 + 3;
			case 9:
				animation.frameIndex = (2 - mountainHeight) * 6 + 4;
			case _:
				animation.frameIndex = (2 - mountainHeight) * 6 + 5;
		}
		System.mouse.initClickable(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function id()
	{
		return SquareID(this);
	}

	public function add(goat:Goat)
	{
		if (goat.square == this)
		{
			hasLocale.updatePositions();
		}
		else
		{
			goat.square = this;
			hasLocale.add(goat);
		}
	}

	public function insert(goat:Goat, slot:Int, callback:Null<Gamepiece->Void> = null)
	{
		hasLocale.insert(goat, slot, callback);
		goat.square = this;
	}

	private function initTokens()
	{
		tokens = [];
		for (i in 0...17 - mountain)
		{
			tokens.push(new Token(x + i * Reg.SPACING, y + i * Reg.SPACING, MountainToken(mountain)));
		}

		freeTokenLocale = new GridLocale(x, y - Reg.TOKEN_SIZE, Reg.SQUARE_SIZE - Reg.TOKEN_SIZE, Reg.TOKEN_SIZE, 1, tokens.length);
		for (token in tokens)
		{
			freeTokenLocale.add(token);
			token.teleportMode = false;
		}

		previewedTokenLocale = new GridLocale(x, y, Reg.SQUARE_SIZE, Reg.TOKEN_SIZE, 1, 4);
		previewedTokens = [];
	}

	private function addTokenPreview()
	{
		var previewedToken = null;
		for (token in tokens)
		{
			if (!token.awarded && !previewedTokens.contains(token))
			{
				previewedToken = token;
			}
		}
		if (previewedToken == null)
		{
			return;
		}
		previewedTokenLocale.add(previewedToken);
		previewedToken.togglePreview(true);
		previewedTokens.push(previewedToken);
	}

	public function toggleTokenPreviews(n:Int)
	{
		var diff = n - previewedTokens.length;
		if (diff > 0)
		{
			for (_ in 0...diff)
				addTokenPreview();
		}
		if (diff < 0)
		{
			for (_ in 0... - diff)
			{
				var token = previewedTokens.pop();
				token.togglePreview(false);
				freeTokenLocale.add(token);
			}
		}
	}

	public function awardTokens(scoreboard:Scoreboard):Float
	{
		var waitTime:Float = 0;
		for (i in 0...previewedTokens.length)
		{
			var token = previewedTokens[i];
			new FlxTimer().start((Reg.maxMoveTime + 0.05) * i, _ ->
			{
				scoreboard.award(token);
			});
			waitTime += Reg.maxMoveTime + 0.05;
		}
		if (waitTime > 0)
		{
			waitTime += Reg.maxMoveTime;
		}
		previewedTokens = [];
		return waitTime;
	}

	public function outOfTokens():Bool
	{
		for (token in tokens)
		{
			if (!token.awarded)
			{
				return false;
			}
		}
		return true;
	}

	public function tokenCount():Int
	{
		var count = 0;
		for (token in tokens)
		{
			if (!token.awarded)
			{
				count += 1;
			}
		}
		return count;
	}
}
