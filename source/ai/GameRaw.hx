package ai;

using Lambda;
using ai.ArrayOps;

typedef Scoreboard = Map<Int, Int>; // Indices 5 to 10 for # of mountain tokens, index 11 for total points

typedef GamestateRaw =
{
	board:Map<Int, Map<Int, Int>>,
	tokens:Map<Int, Int>,
	bonusTokens:Array<Int>,
	scoreboards:Map<Int, Scoreboard>,
	player:Int
}

typedef Move = Map<Int, Int>;
typedef Moves = Array<Move>;

typedef MoveWithMold =
{
	move:Array<Int>,
	mold:Array<Array<Int>>
};

class GameRaw
{
	public static var molds:Array<Array<Array<Int>>> = [
		[[0], [1], [2], [3]], [[0], [1], [2, 3], []], [[0], [1, 2], [3], []], [[0], [1, 3], [2], []], [[0], [1, 2, 3], [], []], [[0, 2], [1], [3], []],
		[[0, 3], [1], [2], []], [[0, 1], [2], [3], []], [[0, 1], [2, 3], [], []], [[0, 3], [1, 2], [], []], [[0, 2], [1, 3], [], []],
		[[0, 1, 3], [2], [], []], [[0, 2, 3], [1], [], []], [[0, 1, 2], [3], [], []], [[0, 1, 2, 3], [], [], []]];
	public static var mountainHeights:Map<Int, Int> = [5 => 4, 6 => 4, 7 => 3, 8 => 3, 9 => 2, 10 => 2];

	public static function blankGamestateRaw():GamestateRaw
	{
		var board = [for (mountain in 5...11) mountain => [for (player in 0...4) player => 0]];
		var tokens = [for (mountain in 5...11) mountain => 17 - mountain];
		var bonusTokens = [6, 9, 12, 15];
		var scoreboards = [for (player in 0...4) player => [for (mountain in 5...12) mountain => 0]];
		var player = 0;
		return {
			board: board,
			tokens: tokens,
			bonusTokens: bonusTokens,
			scoreboards: scoreboards,
			player: player
		};
	}

	public static function isOver(gamestate:GamestateRaw):Bool
	{
		if (gamestate.player == 0)
		{
			var pilesExhausted = 0;
			for (mountain in 5...11)
			{
				pilesExhausted = gamestate.tokens[mountain] == 0 ? pilesExhausted + 1 : pilesExhausted;
			}
			return pilesExhausted >= 3 || gamestate.bonusTokens.length == 0;
		}
		return false;
	}

	public static function winner(gamestate:GamestateRaw):Int
	{
		return [0, 1, 2, 3].largestVia(player -> gamestate.scoreboards[player][11]);
	}

	public static function makeMove(gamestate:GamestateRaw, move:Move):GamestateRaw
	{
		for (mountain in 5...11)
		{
			makeMountainMove(gamestate, mountain, move[mountain]);
		}
		gamestate.player = (gamestate.player + 1) % 4;
		return gamestate;
	}

	public static function copyGame(gamestate:GamestateRaw):GamestateRaw
	{
		// return Reflect.copy(gamestate);
		var board = [
			for (mountain in 5...11)
				mountain => [for (player in 0...4) player => gamestate.board[mountain][player]]
		];
		var tokens = [for (mountain in 5...11) mountain => gamestate.tokens[mountain]];
		var bonusTokens = gamestate.bonusTokens.copy();
		var scoreboards = [
			for (player in 0...4)
				player => [for (mountain in 5...12) mountain => gamestate.scoreboards[player][mountain]]
		];
		var player = gamestate.player;
		return {
			board: board,
			tokens: tokens,
			bonusTokens: bonusTokens,
			scoreboards: scoreboards,
			player: player
		};
	}

	static function makeMountainMove(gamestate:GamestateRaw, mountain:Int, movement:Int)
	{
		var toAward = (gamestate.board[mountain][gamestate.player] + movement) - mountainHeights[mountain];
		if (gamestate.board[mountain][gamestate.player] != mountainHeights[mountain])
		{
			toAward += 1;
		}
		gamestate.board[mountain][gamestate.player] += movement;
		if (gamestate.board[mountain][gamestate.player] >= mountainHeights[mountain])
		{
			gamestate.board[mountain][gamestate.player] = mountainHeights[mountain];
			knockOtherGoatsOff(gamestate, mountain);
			awardTokens(gamestate, mountain, toAward);
		}
	}

	static function knockOtherGoatsOff(gamestate:GamestateRaw, mountain:Int)
	{
		for (player in 0...4)
		{
			if (player == gamestate.player)
			{
				continue;
			}
			if (gamestate.board[mountain][player] == mountainHeights[mountain])
			{
				gamestate.board[mountain][player] = 0;
			}
		}
	}

	static function awardTokens(gamestate:GamestateRaw, mountain:Int, number:Int)
	{
		for (_ in 0...number)
		{
			if (gamestate.tokens[mountain] > 0)
			{
				gamestate.tokens[mountain] -= 1;
				if (completesSet(gamestate, mountain))
				{
					awardBonusToken(gamestate);
				}
				gamestate.scoreboards[gamestate.player][mountain] += 1;
				gamestate.scoreboards[gamestate.player][11] += mountain;
			}
		}
	}

	static function completesSet(gamestate:GamestateRaw, mountain:Int)
	{
		for (otherMountain in 5...11)
		{
			if (otherMountain == mountain)
			{
				continue;
			}
			if (gamestate.scoreboards[gamestate.player][otherMountain] <= gamestate.scoreboards[gamestate.player][mountain])
			{
				return false;
			}
		}
		return true;
	}

	static function awardBonusToken(gamestate:GamestateRaw)
	{
		if (gamestate.bonusTokens.length > 0)
		{
			var bonus = gamestate.bonusTokens.pop();
			gamestate.scoreboards[gamestate.player][11] += bonus;
		}
	}

	public static function diceToNumeric(dice:Array<Int>):Int
	{
		return (dice[0] - 1) + (dice[1] - 1) * 6 + (dice[2] - 1) * 36 + (dice[3] - 1) * 216;
	}

	public static function applyWilds(values:Array<Int>, wilds:Array<Int>):Array<Int>
	{
		var replacedCount = 0;
		var output = [];
		for (value in values)
		{
			if (value == 1)
			{
				output.push(wilds[replacedCount]);
				replacedCount += 1;
			}
			else
			{
				output.push(value);
			}
		}
		return output;
	}

	private static function makeWild(roll:Array<Int>):Array<Array<Int>>
	{
		var wildCount = roll.filter(x -> x == 1).length - 1;
		if (wildCount < 0)
		{
			wildCount = 0;
		}
		return [1, 2, 3, 4, 5, 6].pow(wildCount).map(wilds -> applyWilds(roll, wilds.concat([1])));
	}

	public static function rollToMoves(roll:Array<Int>):Array<MoveWithMold>
	{
		var wildRoll = makeWild(roll);
		// trace(roll);
		// trace(wildRoll);
		var dropOptions = [0, 1].pow(4);

		function getMoves(combination:Array<Int>)
		{
			function optionsFromDropping(moveWithMold:MoveWithMold):Array<MoveWithMold>
			{
				return dropOptions.map(dropOption -> {
					move: dropOption.zipWith(moveWithMold.move, (a, b) -> a * b),
					mold: moveWithMold.mold
				});
			}

			var moldedMoves = molds.map(mold -> {
				move: mold.map(column -> column.map(i -> combination[i]).sum()).map(d -> d < 5 || d > 10 ? 0 : d),
				mold: mold
			}).map(optionsFromDropping).flatten();

			for (moveWithMold in moldedMoves)
			{
				moveWithMold.move.sort((a, b) -> a - b);
			}
			// trace("getMoves called with combination " + combination);
			// trace("yields (filtered) moldedMoves ");
			// for (moldedMove in moldedMoves)
			// {
			//	trace(moldedMove);
			// }
			return moldedMoves;
		}

		var moves = wildRoll.map(getMoves).flatten().nub((a, b) -> a.move.equals(b.move));
		// var converted = moves.map(moveWithMold -> [for (mountain in 5...11) mountain => moveWithMold.move.count(n -> n == mountain)]);
		return moves;
	}
}
