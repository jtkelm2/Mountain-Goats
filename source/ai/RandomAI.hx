package ai;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import gameobjects.*;
import system.*;
import system.Data;

enum DieState
{
	Natural(die:Die);
	Wild(die:Die, val:Int);
}

class RandomAI implements AI
{
	private var ps:PlayState;
	private var player:Int;

	public function new(ps:PlayState, player:Int)
	{
		this.ps = ps;
		this.player = player;
	}

	public function onPrompt(gamestate:Gamestate)
	{
		switch gamestate.gamestateTag
		{
			case DiceRollingGSTag:
				System.events.handle(MouseClicked);
			case PlanningGSTag:
				executeCombination(getRandomCombination());
			case _:
		}
	}

	private function getRandomCombination():Array<Array<DieState>>
	{
		var combination = [for (_ in 0...4) []];
		var shuffledIndices = [for (i in 0...4) i];
		FlxG.random.shuffle(shuffledIndices);
		for (index in shuffledIndices)
		{
			combination[FlxG.random.int(0, 3)].push(Natural(ps.diceBox.dice[index]));
		}
		return combination;
	}

	private function executeCombination(combination:Array<Array<DieState>>)
	{
		for (i in 0...4)
		{
			for (die in combination[i])
			{
				switch die
				{
					case Natural(die):
						System.events.queue(AIPlaceDie(die, i), false);
					case _:
				}
			}
		}

		for (i in 0...4)
		{
			var sum:Int = 0;
			for (dieState in combination[i])
			{
				switch dieState
				{
					case Natural(die):
						sum += die.value;
					case _:
				}
			}
			if (sum >= 5 && sum <= 10)
			{
				System.events.queue(AIAdvanceGoat(sum));
			}
		}

		System.events.queue(MovementsConfirmed);
	}
}
