# Calculation Solitaire

My second test project in HaxeFlixel, this is a mostly-complete implementation of the board game [Mountain Goats](https://boardgamegeek.com/boardgame/305985/mountain-goats), together with AI. Go to [http://jtkelm2.github.io/Calculation-Solitaire/](http://jtkelm2.github.io/Mountain-Goats/) to play!

Features missing from what I would otherwise call a *complete* implementation are as follows:

1. No in-game start menu or explanation of the rules.
2. No proper gameover process. The game simply stops letting you make moves.
3. No way to select which player you are. Easily modified in the code, however, via `System.initAI`.
4. No way to select the number of players. With a few modifications to the code, it wouldn't be hard.
5. Room for improved AI, including difficulty levels.
6. No way to implement basic rules variations, e.g. number of tokens per mountain, or number of mountains exhausted before game end. Easily modified in the code.
7. Room for far better graphics. AI could only assist me so much in asset creation.
8. No logic for handling sprite overlaps in the proper 2.5D way.

Documentation of the code is also lacking. I learned many things along the way, and some design choices were more well thought out than others. To elaborate on the organization of things a little:

* As much as possible, nothing is left to per-frame updates. The game's logic is handled through a discrete event queue (`System.events`), which is capable of handling scripted events (wrapped in an enum type `EventID`) which can be set to resolve immediately or be placed in the queue. This includes events of input from the player (currently, there is some coupling between inputs and actions incurred by inputs), inputs from the AI, and events produced by the game itself in sequence.
    * The event queue is a global instance, but its handling methods are implemented through the specifics of the current `Gamestate`. These `Gamestate`s act somewhat like more granular `FlxState`s, turning them into finite-state automota.
    * Events recently put onto the queue must wait for prior events to finish resolving. By default, an event will resolve instantly (`AutoNext`); by setting the `autonext` field to false in the `queue` call (`ManualNext`), however, the queue will only proceed once `next()` is called somewhere in the code, say through a final tween callback.
        * This greatly reduces the need to rely on hardcoded timer durations and conditional logic, and precludes duplicate event handling (e.g. by spamming an input after its animation has started, but before the internal state changes have finished processing).
        * Nonetheless, I only settled on this architecture late into the coding. Things like `MoveConfirmed` handling in the `Planning` `Gamestate` deserve a rewrite.
        * Generalizing the strictly linear queue into a more general nonlinear handler, where each event has a unique fingerprint, and `next()` is replaced with `end(fingerprint)`, may be in order for future projects.
* `Locale`s are crucial to the automatic positioning of gamepieces, and I've spent a lot of time on their functionality, but I'm not so happy how ugly their internals are. I think rather than an abstract class with so many obscure and fiddly derived functions, a `Locale` ought to be merely a typed interface, with exactly three methods: `add`, `insert`, and `remove`, with callback capabilities. Let implementations of this interface determine the type of objects it accepts and the fiddly inner workings, borrowing methods from a static library if honestly necessary.
    * Also, `Locale`s ought to be anchor-centric. Current implementation of translating/rotating objects of the locale *en masse* is just a hack.
* Speaking of anchors, `RotationAnchor` should support scaling so that I can just properly call it `Anchor`.
* An `AI` is defined as a class whose instances will respond to `onPrompt` calls, with context supplied by the current `Gamestate`. In practice `onPrompt` is called through its helper `System.promptAI()`, which will do nothing in the event that the current player is human.
    * An `AI` can be instantiated from a purely data-centric creature known as an `AIRaw`, through the `AIManager` factory class. An `AIRaw` processes all the raw data associated with a game's state (and only this raw data; in this way, it is entirely decoupled from the game's UI and all that) and returns its favorite move as a response; the `AIManager` handles all the messy translation between the game's internal state and this `AIRaw`.
        * And I do mean messy... I would have done much better to center my game around pure data in the first place, in a way that I don't have extremely fiddly translation involving the state of the `DiceBox`.


Made possible with a Github workflow provided by [https://github.com/HaxeFlixel/game-jam-template](https://github.com/HaxeFlixel/game-jam-template).
