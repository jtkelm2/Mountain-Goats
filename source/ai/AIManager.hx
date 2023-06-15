package ai;

import ai.*;
import ai.AILab;
import ai.GameRaw;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import gameobjects.*;
import system.*;
import system.Data;

using Lambda;
using ai.ArrayOps;

enum DieState
{
	Natural(die:Die);
	Wild(die:Die, val:Int);
}

typedef MoveWithWilds =
{
	move:MoveWithMold,
	wilds:Array<Int>
};

class AIManager implements AI
{
	private var ps:PlayState;
	private var aiRaw:AIRaw;

	public function new(ps:PlayState, aiRaw:AIRaw)
	{
		this.ps = ps;
		this.aiRaw = aiRaw;
	}

	public function onPrompt(gamestate:Gamestate)
	{
		switch gamestate.gamestateTag
		{
			case DiceRollingGSTag:
				System.events.handle(MouseClicked);
			case PlanningGSTag:
				executeRawResponse(getRawResponse());
			case _:
		}
	}

	private function executeRawResponse(moveWithWilds:MoveWithWilds)
	{
		var oneDice:Array<Die> = ps.diceBox.dice.filter(die -> die.value == 1);

		for (i in 0...4)
		{
			for (i in 0...moveWithWilds.wilds.length)
			{
				System.events.queue(AICastWild(oneDice[i], moveWithWilds.wilds[i]));
			}

			for (dieNum in moveWithWilds.move.mold[i])
			{
				var die = ps.diceBox.dice[dieNum];
				System.events.queue(AIPlaceDie(die, i), false);
			}
		}

		for (mountain in moveWithWilds.move.move.filter(i -> i != 0))
		{
			System.events.queue(AIAdvanceGoat(mountain), false);
		}
	}

	private function getRawResponse():MoveWithWilds
	{
		var gamestateRaw = getGamestateRaw();
		var dice = ps.diceBox.dice.map(die -> die.value);
		var oneCount = dice.count(i -> i == 1);
		var wildCount = oneCount - 1 < 0 ? 0 : oneCount - 1;
		function interspersals(wilds:Array<Int>):Array<Array<Int>>
		{
			if (wildCount == 0)
			{
				return oneCount == 0 ? [[]] : [[1]];
			}
			var output = [];
			for (i in 0...wilds.length + 1)
			{
				var wildsCopy = wilds.copy();
				wildsCopy.insert(i, 1);
				output.push(wildsCopy);
			}
			return output;
		}
		var wildPossibilities = [1, 2, 3, 4, 5, 6].pow(wildCount).map(interspersals).flatten();
		var moldedMoves = GameRaw.rollToMoves(dice);

		function convert(values:Array<Int>):Move
		{
			return [for (mountain in 5...11) mountain => values.count(value -> value == mountain)];
		}

		function applyMold(values:Array<Int>, mold:Array<Array<Int>>):Array<Int>
		{
			var output = mold.map(column -> column.map(i -> values[i]).sum());
			output.sort((a, b) -> a - b);
			return output;
		}

		var rawResponseMove = aiRaw(gamestateRaw, moldedMoves.map(moldedMove -> convert(moldedMove.move)));
		var convertedResponseMove = [0, 0, 0, 0];

		for (mountain in (5...11))
		{
			for (_ in 0...rawResponseMove[mountain])
			{
				convertedResponseMove.remove(0);
				convertedResponseMove.push(mountain);
			}
		}
		// trace("AI wants to play: " + convertedResponseMove);

		function fitsMold(mold:Array<Array<Int>>, wilds:Array<Int>):Bool
		{
			var appliedMold = applyMold(GameRaw.applyWilds(dice, wilds), mold);
			for (i in 0...4)
			{
				if (convertedResponseMove[i] != 0 && convertedResponseMove[i] != appliedMold[i])
				{
					return false;
				}
			}
			return true;
		}

		var rawResponse:Null<MoveWithMold> = null;
		for (moldedMove in moldedMoves)
		{
			if (moldedMove.move.equals(convertedResponseMove))
			{
				rawResponse = moldedMove;
				break;
			}
		}
		if (rawResponse == null)
		{
			trace("Didn't find response :(");
			trace(dice);
			trace(rawResponseMove);
			trace(convertedResponseMove);
			for (moldedMove in moldedMoves)
			{
				trace(moldedMove);
			}
		}
		var wildsOutput:Array<Int> = null;
		for (wilds in wildPossibilities)
		{
			if (fitsMold(rawResponse.mold, wilds))
			{
				wildsOutput = wilds;
				break;
			}
		}
		if (wildsOutput == null)
		{
			trace("Failed to find wilds combination :(");
			trace("dice: " + dice);
			trace("rawResponse: " + rawResponse);
			trace("converted: " + convertedResponseMove);
			trace("wild possibilities: " + wildPossibilities);
		}
		return {move: rawResponse, wilds: wildsOutput};
	}

	private function getGamestateRaw():GamestateRaw
	{
		// var board = [for (mountain in 5...11) mountain => [for (player in 0...4) player => 0]];
		// var tokens = [for (mountain in 5...11) mountain => 17 - mountain];
		// var bonusTokens = [6, 9, 12, 15];
		// var scoreboards = [for (player in 0...4) player => [for (mountain in 5...12) mountain => 0]];
		// var player = 0;

		var board:Map<Int, Map<Int, Int>> = [for (mountain in 5...11) mountain => [0 => 0]];
		for (mountain in 5...11)
		{
			for (player in 0...4)
			{
				board[mountain][player] = ps.goats[player][mountain].square.mountainHeight;
			}
		}

		var tokens:Map<Int, Int> = [];
		for (mountain in 5...11)
		{
			var squares = ps.mountains[mountain];
			tokens[mountain] = squares[squares.length - 1].tokenCount();
		}

		var bonusTokens:Array<Int> = [];
		for (token in ps.bonusTokens)
		{
			if (!token.awarded)
			{
				bonusTokens.push(token.value());
			}
		}
		bonusTokens.sort((a, b) -> a - b);

		var scoreboards:Map<Int, Map<Int, Int>> = [for (player in 0...4) player => [5 => 0]];
		for (player in 0...4)
		{
			scoreboards[player][11] = 0;
			for (mountain in 5...11)
			{
				scoreboards[player][mountain] = ps.scoreboards[player].tokensRaw[mountain];
				scoreboards[player][11] += ps.scoreboards[player].tokensRaw[mountain] * mountain;
			}
			scoreboards[player][11] += ps.scoreboards[player].tokensRaw[11];
		}

		var player:Int = ps.player;

		return {
			board: board,
			tokens: tokens,
			bonusTokens: bonusTokens,
			scoreboards: scoreboards,
			player: player
		};
	}
}
