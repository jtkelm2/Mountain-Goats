package ai;

import Main;
import ai.GameRaw;
import flixel.FlxG;
import flixel.math.FlxRandom;
import haxe.Timer;

using Lambda;
using ai.ArrayOps;
using ai.GameRaw;

typedef Heuristic = (GamestateRaw, Int) -> Float; // Gamestate together with player's perspective
typedef MoveHeuristic = (GamestateRaw, Move) -> Float; // Gamestate together with move, computes preference of move
typedef AIRaw = (GamestateRaw, Moves) -> Move;

class AILab
{
	/* public static function evaluateAI(ai:AI, competitorAI:AI, numGames:Int)
		{
			var wins = 0;
			var totalPoints = 0;

			var startTime = Timer.stamp();
			for (_ in 0...numGames)
			{
				var ais = [for (player in 0...4) player => competitorAI];
				var player = FlxG.random.int(0, 3);
				ais[player] = ai;
				var outcome = simulateGame(ais);
				if (outcome.winner() == player)
				{
					wins += 1;
				}
				totalPoints += outcome.scoreboards[player][11];
			}
			var endTime = Timer.stamp();
			var elapsed = endTime - startTime;
			trace("Win percentage " + Math.round(wins / numGames * 1000) / 10 + "% with average score of " + Math.round(10 * totalPoints / numGames) / 10
				+ "; benchmark of " + numGames + " games completed in " + Math.round(elapsed * 10) / 10 + "s (" + Math.round(numGames / elapsed * 1000) / 1000
				+ " games/sec)");
	}*/
	public static function getRandomAIs():Map<Int, AIRaw>
	{
		return [for (player in 0...4) player => randomAI];
	}

	public static function heuristicAI(heuristic:Heuristic):AIRaw
	{
		return (gamestate, moves) ->
		{
			function evaluateMove(move:Move):Float
			{
				var gamestateChild = gamestate.copyGame();
				gamestateChild.makeMove(move);
				var heur = heuristic(gamestateChild, gamestate.player);
				return heur;
			}

			return moves.largestVia(evaluateMove);
		}
	}

	// The move heuristic MAY NOT modify the gamestate in place
	public static function moveHeuristicAI(moveHeuristic:MoveHeuristic):AIRaw
	{
		return (gamestate, moves) ->
		{
			return moves.largestVia(move -> moveHeuristic(gamestate, move));
		}
	}

	// Changes gamestate in place
	/* public static function simulateGame(?ais:Map<Int, AI> = null, ?startingGamestate:GamestateRaw = null):GamestateRaw
		{
			var ais = ais != null ? ais : getRandomAIs();
			var gamestate = startingGamestate != null ? startingGamestate : Gaming.blankGamestateRaw();
			while (!gamestate.isOver())
			{
				gamestate.makeMove(ais[gamestate.player](gamestate, Main.movesMap[FlxG.random.int(0, 1295)]));
			}
			return gamestate;
	}*/
	// Heuristics may always change gamestate in place; be sure you use them on a copy
	/* public static function singularTerminalHeuristic(terminalHeuristic:Heuristic, ?selfAI:AI = null, ?otherAIs:AI = null):Heuristic
		{
			var selfAIModel = selfAI != null ? selfAI : randomAI;
			var otherAIModel = otherAIs != null ? otherAIs : randomAI;

			return (gamestate, player) ->
			{
				var ais = [for (i in 0...4) i => otherAIModel];
				ais[player] = selfAIModel;
				simulateGame(ais, gamestate);
				return terminalHeuristic(gamestate, player);
			}
		}

		public static function multipleTerminalHeuristic(terminalHeuristic:Heuristic, repetitions:Int = 1, ?selfAI:AI = null, ?otherAIs:AI = null):Heuristic
		{
			var selfAIModel = selfAI != null ? selfAI : randomAI;
			var otherAIModel = otherAIs != null ? otherAIs : randomAI;

			return (gamestate, player) ->
			{
				var ais = [for (i in 0...4) i => otherAIModel];
				ais[player] = selfAIModel;

				var average:Float = 0;
				for (_ in 0...repetitions)
				{
					average += terminalHeuristic(simulateGame(ais, gamestate.copyGame()), player);
				}
				return average / repetitions;
			}
	}*/
	static var weightMove:MoveHeuristic = (_, move) ->
	{
		var result = 0;
		for (mountain in 5...11)
		{
			result += mountain * move[mountain];
		}
		return result;
	}

	/*public static function customTokenizedWeightMove(mountainValues:Map<Int,Float>):MoveHeuristic {
		return (gamestate, move) -> {
			var result:Float = 0;
			for (mountain in 5...11) {
				result += (gamestate.tokens[mountain] == 0 ? 0 : 1) * mountainValues[mountain] * move[mountain];
			}
			return result;
		};
	}*/
	// public static var mountainValues:Map<Int,Float> = [5 => 3.23, 6 => 4.19, 7 => 5.17, 8 => 6.13, 9 => 7.11, 10 => 8.07];
	// public static var testAI:AI = moveHeuristicAI(customTokenizedWeightMove(mountainValues));

	static function sign(f:Float):Int
	{
		if (f > 0)
		{
			return 1;
		}
		if (f < 0)
		{
			return -1;
		}
		return 0;
	}

	static var relativityBias = [0 => 2, 1 => 0.5, 2 => 0.5];

	static function relativize(heuristic:Heuristic):Heuristic
	{
		return (gamestate, player) ->
		{
			var myScore = heuristic(gamestate.copyGame(), player);
			var otherScores:Map<Int, Float> = [];
			var otherRankings:Array<Int> = [];

			for (otherPlayer in 0...4)
			{
				if (otherPlayer == player)
				{
					continue;
				}
				otherScores[otherPlayer] = heuristic(gamestate.copyGame(), otherPlayer);
				otherRankings.push(otherPlayer);
			}
			otherRankings.sort((a, b) -> sign(otherScores[b] - otherScores[a]));

			for (otherPlayer in 0...4)
			{
				if (otherPlayer == player)
				{
					continue;
				}
				myScore -= relativityBias[otherRankings.indexOf(otherPlayer)] * otherScores[otherPlayer];
			}
			return myScore;
		}
	}

	public static var tokenizedWeightMove:MoveHeuristic = (gamestate, move) ->
	{
		var result:Float = 0;
		for (mountain in 5...11)
		{
			result += (gamestate.tokens[mountain] == 0 ? 0 : 1) * mountain * move[mountain];
		}
		return result;
	}

	// public static var weightHeuristic
	public static var totalScoreHeuristic:Heuristic = (gamestate, player) -> gamestate.scoreboards[player][11];
	public static var placementHeuristic:Heuristic = (gamestate, player) ->
	{
		var rankings = [0, 1, 2, 3];
		rankings.sort((a, b) -> gamestate.scoreboards[a][11] - gamestate.scoreboards[b][11]);
		return rankings.indexOf(player);
	}

	public static var handcraftScoreHeuristic:Heuristic = (gamestate, player) ->
	{
		var total:Float = gamestate.scoreboards[player][11] * 100;
		var smallestTokenPileSize = 4;
		for (mountain in 5...11)
		{
			if (gamestate.scoreboards[player][mountain] < smallestTokenPileSize)
			{
				smallestTokenPileSize = gamestate.scoreboards[player][mountain];
			}
		}
		for (mountain in 5...11)
		{
			if (gamestate.tokens[mountain] == 0)
			{
				continue;
			}
			var mountainBonus:Float = gamestate.scoreboards[player][mountain] == smallestTokenPileSize ? 2 : 0;
			// total += gamestate.board[mountain][player] * (mountain + mountainBonus - 1.00013);
			total += gamestate.board[mountain][player] * (mountain + mountainBonus);
		}
		return total;
	}

	public static var handcraftScoreHeuristic2:Heuristic = (gamestate, player) ->
	{
		var otherPlayers = [];
		for (otherPlayer in 0...4)
		{
			if (otherPlayer != player)
			{
				otherPlayers.push(otherPlayer);
			}
		}
		var total:Float = gamestate.scoreboards[player][11];
		var smallestTokenPileSize = 4;
		for (mountain in 5...11)
		{
			if (gamestate.scoreboards[player][mountain] < smallestTokenPileSize)
			{
				smallestTokenPileSize = gamestate.scoreboards[player][mountain];
			}
		}
		for (mountain in 5...11)
		{
			if (gamestate.tokens[mountain] == 0)
			{
				continue;
			}
			var topOfMountainBias = 0;
			if (gamestate.board[mountain][player] == GameRaw.mountainHeights[mountain])
			{
				topOfMountainBias = -1; // 85.7%
			}
			// var nextPlayer = otherPlayers.largestVia(otherPlayer -> gamestate.board[mountain][otherPlayer]);
			// var tail = gamestate.board[mountain][player] - gamestate.board[mountain][nextPlayer];
			// var tailBias = [-4 => 0, -3 => 0, -2 => -1, -1 => -1, 0 => 0.5, 1 => 0.5, 2 => 0, 3 => 0, 4 => 0][tail];
			var mountainBonus:Float = gamestate.scoreboards[player][mountain] == smallestTokenPileSize ? 1 : 0;
			total += gamestate.board[mountain][player] * (mountain + mountainBonus + topOfMountainBias - 1.00013);
		}
		return total;
	}

	public static var handcraftScoreAI2:AIRaw = heuristicAI(relativize(handcraftScoreHeuristic2));

	// Win percentage 83.9% with average score of 109.7    (37.388 games/sec)             TOKENIZEDWEIGHTEDMOVER STANDARD HERE AND ABOVE
	public static var handcraftScoreAI:AIRaw = heuristicAI(handcraftScoreHeuristic);

	// Win percentage 99.4% with average score of 132.8    (100 games/sec)
	// 45% win rate against room full of tokenizedWeightedMovers
	public static var scoreNaiveAI:AIRaw = heuristicAI(totalScoreHeuristic);

	// Win percentage 92.2% with average score of 116.7    (80 games/sec)
	public static var placementNaiveAI:AIRaw = heuristicAI(placementHeuristic);

	// Win percentage 92% with average score of 121.3    (517 games/sec)
	public static var tokenizedWeightedMoverAI:AIRaw = moveHeuristicAI(tokenizedWeightMove);

	// Win percentage 89.9% with average score of 119    (615 games/sec)
	public static var weightedMoverAI:AIRaw = moveHeuristicAI(weightMove);

	// Win percentage 80.1% with average score of 113.7
	public static var lastAI:AIRaw = (gamestate, moves) ->
	{
		return moves.last();
	}

	// Win percentage 57.3% with average score of 103.4
	public static var moverAI:AIRaw = (gamestate, moves) ->
	{
		return moves.largestVia(move -> move.sum());
	}

	// Win percentage 25.0% with average score of 89.2    (666 games/sec)
	public static var randomAI:AIRaw = (gamestate, moves) ->
	{
		return FlxG.random.getObject(moves);
	}

	// Win percentage 0% with average score of 41    (570 games/sec)
	public static var snailAI:AIRaw = (gamestate, moves) ->
	{
		return moves[1];
	}

	// Win percentage 0% with average score of 0
	public static var nothingAI:AIRaw = (gamestate, moves) ->
	{
		return moves[0];
	}
	// Terminal heuristic guys must be placed at the bottom due to initialization timings...
	// Win percentage 61% with average score of 105.9    (2.5 games/sec)
	// public static var sthScoreAI:AI = heuristicAI(singularTerminalHeuristic(totalScoreHeuristic, weightedMoverAI));
	// public static var sthScoreAI10:AI = heuristicAI(multipleTerminalHeuristic(totalScoreHeuristic, 10, weightedMoverAI));
	// public static var sthPlacementAI:AI = heuristicAI(singularTerminalHeuristic(placementHeuristic));
}
