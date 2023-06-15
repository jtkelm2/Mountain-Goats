package system;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite.IFlxSprite;
import flixel.FlxSprite;
import flixel.util.FlxSignal;
import states.*;
import system.Data;

enum NextWrapper
{
	AutoNext(eventID:EventID);
	ManualNext(eventID:EventID);
}

class Events extends FlxBasic
{
	private var eventQueue:Array<NextWrapper>;

	private var ps:PlayState;
	private var currentGamestate:Gamestate;

	public var planning:Gamestate;
	public var diceRolling:Gamestate;
	public var gameover:Gamestate;

	public var nextCallback:Null<Gamepiece->Void>;

	public function new(ps:PlayState)
	{
		super();
		eventQueue = [];
		this.ps = ps;
		nextCallback = _ ->
		{
			next();
		}
	}

	public function initGamestate()
	{
		planning = new Planning(ps);
		diceRolling = new DiceRolling(ps);
		gameover = new Gameover(ps);

		currentGamestate = diceRolling.refresh();
	}

	private function wrappedHandle(wrappedEvent:NextWrapper)
	{
		switch wrappedEvent
		{
			case AutoNext(eventID):
				currentGamestate.handle(eventID);
				next();
			case ManualNext(eventID):
				currentGamestate.handle(eventID);
		}
	}

	public function handle(eventID:EventID)
	{
		currentGamestate.handle(eventID);
	}

	public function queue(eventID:EventID, autonext:Bool = true)
	{
		var pushedEvent = autonext ? AutoNext(eventID) : ManualNext(eventID);
		if (eventQueue.push(pushedEvent) == 1)
		{
			wrappedHandle(pushedEvent);
		}
	}

	public function next()
	{
		eventQueue.shift();
		if (eventQueue.length > 0)
		{
			wrappedHandle(eventQueue[0]);
		}
	}

	public function switchState(nextGamestate:Gamestate, promptAI:Bool = false)
	{
		// currentGamestate.kill();
		// nextGamestate.revive();
		currentGamestate = nextGamestate.refresh();
		if (promptAI)
		{
			System.promptAI(currentGamestate);
		}
	}
}
