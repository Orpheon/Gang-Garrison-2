/*
The bot object is called BotPlayer (in "In-game Objects") and is more or less a copy of the normal Player object.
PlayerControl was condensed in a line, namely in user_event(14), when BotInputConverter is called.

BotInputConverter calls BotMain where the entire AI code lies.
Afterwards, BotInputConverter compiles this into a byte and sends this with the aimDirection.
That is how the bot gives itself its movements.

The script CreateBot() makes a bot object each time it is called.
I call it every time step in GameServerBeginStep as long as global.bot_num (a counter created for this purpose) is under the number of bots the hoster wished.

BotInit() resets the bot, makes it decide again where to go and destroys any reverses. It's called every time the bot spawns and when an enemy in range dies or gets out of range.

The AI itself:
The script BotMain controls everything; first it aims, and then finds out whether it should be fighting or no.
If it is, BotFight and co get executed. If not, the bot just moves to the nearest objective.
BotMove is a stone-old movement (jumping and reversing) script that reads nodes. Since I hate nodes, I haven't touched that code for ages.
Instead; there is the BotAutonomousMove, which handles all map-independent movement. Improvement here is needed. Warning: Beware of bugs!

The group "Map Modes" contains exactly what it says, the scripts that decide in which direction the objective is.
This is probably the most buggy part of the entire AI, and I REALLY need help doing them.

BotGetTarget is mostly copied from the sentry code.
Yes, it does the entire thing twice, first to check the nearest Enemy in sight (you can shoot at), and if there are none it reverts back to simply the nearest Enemy.
BotAim is where all the prediction and aiming is done, and BotShoot is there mostly for historical reasons (It's contents were moved to BotFight).
DemoAim is an experimental (read: not working) Demoman aiming script. I still need to test and fine-tune this, but the concept is there.



If you want to use this as a framework for your own AI, feel free to do so. Erase all scripts in "Bot" except BotInputConverter, and replace the line there "BotMain()" with your AI.
IMPORTANT: If you want a bot capable of jumping, you need to define the "pressed" variable. This is because gg2 only records jumping if you've just pressed it.
If you're holding it, nothing will happen. "pressed" makes sure that every second frame you want to jump it doesn't jump, simulating someone spamming jump 15/sec.
Also, don't forget that this is called from the BotPlayer obect, NOT from the Character. To get positions and stuff, use object.x, and not x.
Or you can go edit the user event 14 of the BotPlayer and make it a "with object".


Feel free to improve as much as you want.
