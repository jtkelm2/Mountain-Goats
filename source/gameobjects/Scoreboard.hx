package gameobjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gadgets.*;
import system.*;
import system.Data;

using ai.ArrayOps;

class Scoreboard extends FlxSprite
{
	private var turnOrder:Int;

	public var rank:FlxSprite;

	public var tokensRaw:Map<Int, Int>; // Indices 5-10 for mountain tokens, and index 11 for points from bonus tokens

	// public var scores:Array<FlxText>; // Indices 0-5 for mountains, index 6 for bonuses, index 7 for total
	private var tokenLocales:Map<Int, Locale>; // Locales for tokens indexed by mountain

	public var bonusTokensAwarded:Int;

	private var bonusTokenLocale:Locale;

	public var score:FlxText;

	private var anchor:RotationAnchor;

	public var player:Int;

	// public var tokens:Map<TokenType, Int>;

	public function new(player:Int)
	{
		super();
		loadGraphic("assets/panel.png", true, Reg.PANEL_WIDTH, Reg.PANEL_HEIGHT);
		animation.frameIndex = player;
		this.player = player;
		anchor = new RotationAnchor(origin.x, origin.y);
		anchor.add(this);
		turnOrder = 0;
		tokensRaw = [for (i in 5...12) i => 0];
		bonusTokensAwarded = 0;
		initRank();
		initScore();
		initLocales();
		rotate(4 - player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function initLocales()
	{
		tokenLocales = [];
		for (mountain in 5...11)
		{
			tokenLocales[mountain] = new GridLocale(x + Reg.SPACING + (mountain - 5) * Reg.TOKEN_SIZE, y + Reg.SPACING - 1, Reg.TOKEN_SIZE,
				2 * (Reg.PANEL_HEIGHT - Reg.TOKEN_SIZE), 12, 1);
			anchor.add(tokenLocales[mountain]);
		}
		bonusTokenLocale = new GridLocale(score.x, score.y, 0, 0, 4, 1, false);
		anchor.add(bonusTokenLocale);
	}

	/* public function initScores()
		{
			var scoreX:Float = x;
			scores = [];
			for (mountain in 5...11)
			{
				scores.push(initScore(scoreX, y + Reg.TOKEN_SIZE));
				scoreX += Reg.TOKEN_SIZE;
			}
			scores.push(initScore(scoreX, y + Reg.TOKEN_SIZE, 0.7, 2));

			scoreX += 2 * Reg.TOKEN_SIZE;
			scores.push(initScore(scoreX, y + 1.5 * Reg.TOKEN_SIZE, 1, 4));

			for (score in scores)
			{
				anchor.add(score);
			}

			tokens = [];
			for (mountain in 5...11)
			{
				tokens[MountainToken(mountain)] = 0;
			}
			for (k in 0...4)
			{
				tokens[BonusToken(15 - k * 3)] = 0;
			}
	}*/
	private function initScore()
	{
		score = new FlxText();
		score.x = x + Reg.PANEL_WIDTH - Reg.RANK_SIZE;
		score.y = y + Reg.PANEL_HEIGHT - Reg.TOKEN_SIZE;
		score.text = "0";
		score.size = Math.round(0.8 * Reg.TOKEN_SIZE);
		score.fieldWidth = Reg.RANK_SIZE;
		score.alignment = CENTER;
		// score.color = Reg.playerTextColors[player];
		anchor.add(score);
		/* var score = new FlxText();
			score.x = scoreX;
			score.y = scoreY;
			score.text = Std.string(0);
			score.size = Std.int(size * Reg.TOKEN_SIZE);
			score.fieldWidth = fieldWidth * Reg.TOKEN_SIZE;
			score.alignment = CENTER;
			score.color = Reg.playerTextColors[player];
			return score; */
	}

	private function initRank()
	{
		rank = new FlxSprite(x + width - Reg.RANK_SIZE, y + Reg.SPACING);
		rank.loadGraphic("assets/rank.png", true, Reg.RANK_SIZE);
		anchor.add(rank);
	}

	public function changeRank(newRank:Int)
	{
		rank.animation.frameIndex = newRank;
	}

	public function rotate(times:Int):Scoreboard
	{
		turnOrder = (turnOrder - times + 4) % 4;

		var oldMidpoint = getMidpoint();
		var newMidpoint = Reg.PANEL_PLACEMENTS[turnOrder];
		/* switch turnOrder
			{
				case 0:
					destX = Reg.centerX - Reg.PANEL_WIDTH / 2;
					destY = Reg.centerY + Reg.nonUIHeight / 2;
				case 1:
					destX = Reg.centerX + Reg.nonUIWidth / 2 - Reg.PANEL_WIDTH / 2 + Reg.PANEL_HEIGHT / 2;
					destY = Reg.centerY - Reg.PANEL_HEIGHT / 2;
				case 2:
					destX = Reg.centerX - Reg.PANEL_WIDTH / 2;
					destY = 0;
				case 3:
					destX = Reg.PANEL_HEIGHT / 2 - Reg.PANEL_WIDTH / 2;
					destY = Reg.centerY - Reg.PANEL_HEIGHT / 2;
		}*/
		anchor.x += newMidpoint.x - oldMidpoint.x;
		anchor.y += newMidpoint.y - oldMidpoint.y;
		oldMidpoint.put();
		anchor.angle += 90 * times;
		return this;
	}

	public function award(token:Token)
	{
		// tokens[token.tokenType] += 1;
		switch token.tokenType
		{
			case MountainToken(mountain):
				token.togglePreview(false);
				tokenLocales[mountain].insert(token, 0, _ ->
				{
					token.awarded = true;
					updateScores();
				});
				tokensRaw[mountain] += 1;
			case BonusToken(n):
				token.togglePreview(false);
				bonusTokenLocale.add(token, _ ->
				{
					token.awarded = true;
					System.effects.fadeOut(token);
					updateScores();
				});
				tokensRaw[11] += n;
				bonusTokensAwarded += 1;
		}
	}

	function updateScores()
	{
		var total = 0;
		for (n in 0...6)
		{
			// scores[n].text = Std.string(tokensRaw[n + 5]);
			total += tokensRaw[n + 5] * (n + 5);
		}
		// scores[6].text = Std.string(tokensRaw[11]);
		total += tokensRaw[11];
		score.text = Std.string(total);
	}
}
