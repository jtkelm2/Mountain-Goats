package;

import ai.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gadgets.*;
import gameobjects.*;
import system.*;
import system.Data;

using Lambda;

class PlayState extends FlxState
{
	var indicator:FlxText;

	public var player:Int;
	public var mountains:Map<Int, Array<Square>>; // Squares indexed by mountain (5-10), then by height (0-4)
	public var goats:Map<Int, Map<Int, Goat>>; // Goats indexed by player, then by mountain
	public var scoreboards:Map<Int, Scoreboard>; // Scoreboards indexed by player
	public var diceBox:DiceBox;

	public var diceRoller:FlxSprite;

	public var moveConfirmButton:MoveConfirmButton;
	public var mountaintopQueryRegion:QueryRegion;

	public var bonusTokens:Array<Token>;
	public var bonusTokenLocale:Locale;
	public var bonusTokensAwarded:Int;

	public var gameEndingThisRound:Bool;

	override public function create()
	{
		super.create();
		initBG();
		System.initSystem(this);
		initMoveConfirmButton();
		initScoreboards();
		initBoard();
		initGoats();
		initDiceBox();
		initTokens();
		System.events.initGamestate();
		// indicator = new FlxText();
		// indicator.size = 16;
		// indicator.y = Reg.PANEL_HEIGHT;
		// add(indicator);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		/* if (System.mouse.hovered == null)
			{
				indicator.text = "";
			}
			else
			{
				var tag = System.data.idToTag(System.mouse.hovered);
				indicator.text = Std.string(tag);
		}*/
		// indicator.text = "(" + FlxG.mouse.x + "," + FlxG.mouse.y + ")";
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.resetGame();
		}

		/* if (FlxG.keys.justPressed.A)
			{
				for (die in diceBox.dice)
				{
					die.value = 1;
					die.animation.frameIndex = 0;
					die.isWild = true;
				}
		}*/
		if (FlxG.keys.justPressed.ALT)
		{
			FlxG.timeScale = 20;
		}
		if (FlxG.keys.justReleased.ALT)
		{
			FlxG.timeScale = 1;
		}
	}

	function initBG()
	{
		add(new FlxSprite(0, 0, "assets/bg.png"));
	}

	function initMoveConfirmButton()
	{
		moveConfirmButton = new MoveConfirmButton(Reg.MOVE_CONFIRM_X, Reg.MOVE_CONFIRM_Y, null, () ->
		{
			if (moveConfirmButton.alpha > 0.1)
			{
				System.events.queue(MovementsConfirmed);
			}
		});
		moveConfirmButton.alpha = 0;
		add(moveConfirmButton);
	}

	function initBoard()
	{
		var columnSizes = [5 => 4, 6 => 4, 7 => 3, 8 => 3, 9 => 2, 10 => 2];
		var x = Reg.BOARD_X;
		var y = Reg.BOARD_Y;
		mountaintopQueryRegion = new QueryRegion().addRegionGrid(x, y, 6 * Reg.SQUARE_SIZE, Reg.TOKEN_SIZE, 1, 6);
		mountains = [for (i in 5...11) i => []];
		for (mountain in 5...11)
		{
			y = Reg.BOARD_Y + Reg.TOKEN_SIZE;
			mountains[mountain].push(initSquare(x, y, Mountaintop, mountain, columnSizes[mountain]));
			y += Reg.SQUARE_SIZE;
			for (row in 0...columnSizes[mountain] - 1)
			{
				mountains[mountain].push(initSquare(x, y, Mountain, mountain, columnSizes[mountain] - row - 1));
				y += Reg.SQUARE_SIZE;
			}
			mountains[mountain].push(initSquare(x, y, MountainFoot, mountain, 0));
			mountains[mountain].reverse();
			x += Reg.SQUARE_SIZE;
			y = Reg.BOARD_Y;
		}
	}

	function initSquare(x, y, squareType, mountain, mountainHeight)
	{
		var square = new Square(x, y, squareType, mountain, mountainHeight);
		add(square);
		return square;
	}

	function initGoats()
	{
		goats = [];
		for (player in 0...4)
		{
			goats[player] = [for (mountain in 5...11) mountain => initGoat(player, mountains[mountain][0])];
		}
	}

	function initGoat(player:Int, square:Square):Goat
	{
		var goat = new Goat(player, square);
		add(goat);
		return goat;
	}

	function initScoreboards()
	{
		scoreboards = [];
		for (player in 0...4)
		{
			initScoreboard(player);
		}
	}

	function initScoreboard(player:Int)
	{
		var scoreboard = new Scoreboard(player);
		scoreboards[player] = scoreboard;
		add(scoreboard);
		add(scoreboard.score);
		add(scoreboard.rank);
		return scoreboard;
	}

	function initDiceBox()
	{
		diceRoller = new FlxSprite(0, 0, "assets/diceroller.png");
		add(diceRoller);
		diceBox = new DiceBox(Reg.DICEBOX_X, Reg.DICEBOX_Y, FlxColor.WHITE);
		add(diceBox);
		for (die in diceBox.dice)
		{
			add(die);
		}
		return diceBox;
	}

	function initTokens()
	{
		for (mountain in 5...11)
		{
			for (token in mountains[mountain][mountains[mountain].length - 1].tokens)
			{
				add(token);
			}
		}

		bonusTokens = [];
		bonusTokenLocale = new GridLocale(Reg.SPACING, FlxG.height - Reg.SPACING - Reg.TOKEN_SIZE, 2 * Reg.TOKEN_SIZE, Math.round(1.25 * Reg.TOKEN_SIZE), 4,
			1, true, 2);
		bonusTokensAwarded = 0;

		for (k in 0...4)
		{
			var token = new Token(0, 0, BonusToken(3 * k + 6));
			add(token);
			bonusTokens.insert(0, token);
			bonusTokenLocale.insert(token, 0);
		}
		for (token in bonusTokens)
		{
			token.teleportMode = false;
		}
	}

	public function checkForGameEnd()
	{
		var mountainsExhausted = 0;
		for (mountain in 5...11)
		{
			var squares = mountains[mountain];
			if (squares[squares.length - 1].outOfTokens())
			{
				mountainsExhausted += 1;
			}
		}
		var allBonusTokensAwarded = true;
		for (token in bonusTokens)
		{
			if (!token.awarded)
			{
				allBonusTokensAwarded = false;
			}
		}
		gameEndingThisRound = mountainsExhausted >= 4 || allBonusTokensAwarded;
	}

	public function nextPlayer()
	{
		player = (player + 1) % 4;
		for (scoreboard in scoreboards.iterator())
		{
			scoreboard.rotate(1);
		}

		var nextState = gameEndingThisRound && player == 0 ? System.events.gameover : System.events.diceRolling;
		System.effects.fadeOut(moveConfirmButton);
		System.events.queue(SwitchState(nextState));
	}

	public function updateRanks()
	{
		var totalScores:Array<Int> = [for (player in 0...4) Std.parseInt(scoreboards[player].score.text)];
		totalScores.sort((a, b) -> b - a);
		for (player in 0...4)
		{
			var myScore = Std.parseInt(scoreboards[player].score.text);
			scoreboards[player].changeRank(totalScores.count(otherScore -> otherScore > myScore));
		}
	}
}
