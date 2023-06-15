package system;

import ai.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import system.*;
import system.Data;

class System
{
	public static var ps:PlayState;

	public static var events:Events;
	public static var dragger:Dragger;
	public static var effects:Effects;
	public static var mouse:Mouse;
	public static var data:Data;
	public static var players:Map<Int, PlayerID>;

	public static function initSystem(playState:PlayState)
	{
		ps = playState;
		Reg.initReg();

		ps.player = 0;
		ps.gameEndingThisRound = false;

		data = new Data();
		dragger = new Dragger();
		ps.add(dragger);
		effects = new Effects();
		ps.add(effects);
		mouse = new Mouse();
		ps.add(mouse);
		events = new Events(ps);
		ps.add(events);

		initAI(ps);
	}

	private static function initAI(ps:PlayState)
	{
		players = [
			0 => Human, // AI(new AIManager(ps, 0, AILab.handcraftScoreAI)),
			1 => AI(new AIManager(ps, AILab.handcraftScoreAI)),
			2 => AI(new AIManager(ps, AILab.handcraftScoreAI)),
			3 => AI(new AIManager(ps, AILab.handcraftScoreAI))
		];
	}

	public static function promptAI(gamestate:Gamestate)
	{
		switch players[ps.player]
		{
			case Human:
			case AI(ai):
				ai.onPrompt(gamestate);
		}
	}
}
