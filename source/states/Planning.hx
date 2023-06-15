package states;

// import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import gameobjects.*;
import system.*;
import system.Data;

using Lambda;

class Planning implements Gamestate // extends FlxBasic
{
	var ps:PlayState;
	var originalSquares:Map<Goat, Square> = []; // Original squares of the player's goats
	var originalSlots:Map<Goat, Int> = []; // Original slots of the player's goats
	var movementsConfirming:Bool;
	var firstMoveMade:Bool;

	var movements:Map<Int, Int>; // Previewed movements of the goats (0 = no movement, 1 = one higher, etc), indexed by mountain

	public var gamestateTag:Tag = PlanningGSTag;

	public function new(ps:PlayState)
	{
		this.ps = ps;
	}

	public function refresh():Gamestate
	{
		movements = [for (mountain in 5...11) mountain => 0];
		for (mountain in 5...11)
		{
			var goat = ps.goats[ps.player][mountain];
			originalSquares[goat] = goat.square;
			originalSlots[goat] = goat.inLocale.getSlot(goat);
		}
		movementsConfirming = false;
		firstMoveMade = false;
		System.mouse.setActive([GoatTag, DieTag, TokenTag]);
		return this;
	}

	public function handle(eventID:EventID)
	{
		switch eventID
		{
			case MouseDown(DieID(die)):
				System.dragger.dragged = die;
				System.mouse.setActive([DiceBoxTag]);

			case MouseDown(GoatID(goat)):
				if (goat.player == ps.player && !goat.isMoving)
				{
					System.dragger.dragged = goat;
					System.mouse.setActive([SquareTag]);
				}

			case MouseDown(TokenID(_)):
				var queryResult = ps.mountaintopQueryRegion.query();
				if (queryResult != null)
				{
					var mountaintopClicked = queryResult + 5;
					var goat = ps.goats[ps.player][mountaintopClicked];
					if (goat.square.squareType == Mountaintop)
					{
						for (token in goat.square.tokens)
						{
							if (token.isMoving)
							{
								return;
							}
						}
						// checkFirstMove();
						movements[goat.square.mountain] += 1;
						judgeMovements();
					}
				}

			case MouseWheel(DieID(die)):
				if (die.changeWild(FlxG.mouse.wheel, ps.diceBox))
				{
					judgeMovements();
				}

			case DraggerDropped(GoatID(goat)):
				switch System.mouse.hovered
				{
					case SquareID(square):
						var result = isValidDrop(goat, square);
						if (result == null)
						{
							cancelDrop(goat);
						}
						else
						{
							// checkFirstMove();
							movements[goat.square.mountain] = result;
						}
					case _:
						cancelDrop(goat);
				}
				judgeMovements();
				System.mouse.setActive([GoatTag, DieTag, TokenTag]);

			case DraggerDropped(DieID(die)):
				switch System.mouse.hovered
				{
					case DiceBoxID(diceBox):
						var slot = diceBox.queryRegion.query();
						if (slot == null)
						{
							die.inLocale.updatePositions();
						}
						else
						{
							diceBox.toSlot(slot, die);
							judgeMovements();
						}
					case _:
						die.inLocale.updatePositions();
				}
				System.mouse.setActive([GoatTag, DieTag, TokenTag]);

			case MovementsConfirmed:
				if (movementsConfirming)
					return;
				movementsConfirming = true;
				var mountainResolvingWaitTime:Float = 0;
				ps.diceBox.unreserveAll();

				for (mountain in 5...11)
				{
					ps.goats[ps.player][mountain].togglePreview(false);
					mountainResolvingWaitTime = FlxMath.bound(resolveMountaintop(mountain), mountainResolvingWaitTime);
				}

				new FlxTimer().start(mountainResolvingWaitTime, _ ->
				{
					var bonusTokenWaitTime = resolveBonusTokens();
					new FlxTimer().start(bonusTokenWaitTime, _ ->
					{
						ps.checkForGameEnd();
						ps.updateRanks();
						ps.nextPlayer();
					});
				});

			case SwitchState(gamestate):
				System.events.switchState(gamestate);

			case AICastWild(die, value):
				var delta = value - die.value;
				if (delta != 0)
				{
					die.changeWild(delta, ps.diceBox);
				}
			case AIPlaceDie(die, slot):
				System.mouse.setActive([]);
				ps.diceBox.toSlot(slot, die, System.events.nextCallback);
			case AIAdvanceGoat(mountain):
				checkFirstMove();
				movements[mountain] += 1;
				judgeMovements();
				new FlxTimer().start(1, _ ->
				{
					System.events.next();
				});
			case _:
		}
	}

	private function isValidDrop(goat:Goat, square:Square):Null<Int>
	{
		if (goat.square.mountain == square.mountain)
		{
			return square.mountainHeight - originalSquares[goat].mountainHeight;
		}
		else
		{
			return null;
		}
	}

	private function judgeMovements()
	{
		var results = ps.diceBox.judgeMovements(movements);
		for (mountain in 5...11)
		{
			var goat = ps.goats[ps.player][mountain];

			if (results[mountain] && movements[mountain] > 0)
			{
				checkFirstMove();
				var originalSquare = originalSquares[goat];

				var newHeight:Int = originalSquare.mountainHeight + movements[mountain];
				var mountaintopHeight = ps.mountains[mountain].length - 1;

				var tokensToPreview = newHeight - mountaintopHeight;
				if (originalSquare.squareType != Mountaintop)
				{
					tokensToPreview += 1;
				}

				var newSquare = ps.mountains[mountain][FlxMath.minInt(newHeight, mountaintopHeight)];

				newSquare.add(goat);
				if (newSquare.squareType == Mountaintop)
				{
					newSquare.toggleTokenPreviews(tokensToPreview);
				}
				goat.togglePreview(true);
			}
			else
			{
				cancelDrop(goat);
			}
		}
	}

	private function cancelDrop(goat:Goat)
	{
		goat.togglePreview(false);

		if (goat.square.squareType == Mountaintop)
		{
			goat.square.toggleTokenPreviews(0);
		}

		if (originalSquares[goat] != goat.square)
		{
			originalSquares[goat].insert(goat, originalSlots[goat]);
		}
		else
		{
			goat.inLocale.updatePositions();
		}

		movements[goat.square.mountain] = 0;
	}

	private function resolveMountaintop(mountain:Int):Float
	{
		var waitTime:Float = 0;

		var goat = ps.goats[ps.player][mountain];
		if (goat.square.squareType == Mountaintop)
		{
			var mountainFoot = ps.mountains[mountain][0];
			waitTime = FlxMath.bound(goat.square.awardTokens(ps.scoreboards[ps.player]), waitTime);
			for (otherPlayer in 0...4)
			{
				if (otherPlayer != ps.player)
				{
					var otherGoat = ps.goats[otherPlayer][mountain];
					if (otherGoat.square.squareType == Mountaintop)
					{
						waitTime = FlxMath.bound(2 * Reg.maxMoveTime, waitTime);
						mountainFoot.add(otherGoat);
					}
				}
			}
		}
		return waitTime;
	}

	private function resolveBonusTokens():Float
	{
		var minTokenCount = 999;
		for (mountain in 5...11)
		{
			minTokenCount = FlxMath.minInt(minTokenCount, ps.scoreboards[ps.player].tokensRaw[mountain]);
		}

		return awardBonusTokens(minTokenCount - ps.scoreboards[ps.player].bonusTokensAwarded);
	}

	private function awardBonusTokens(quantity:Int):Float
	{
		var waitTime:Float = 0;

		for (_ in 0...quantity)
		{
			for (token in ps.bonusTokens)
			{
				if (!token.awarded)
				{
					ps.scoreboards[ps.player].award(token);
					waitTime = Reg.maxMoveTime + 2;
					break;
				}
			}
		}
		return waitTime;
	}

	private function checkFirstMove()
	{
		if (!firstMoveMade)
		{
			System.effects.fadeIn(ps.moveConfirmButton);
			firstMoveMade = true;
		}
	}
}
