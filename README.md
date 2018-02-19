![Vita](vita_logo2.png)

# Vita
A generic energy / life system for Defold

Vita is for games where you use an auto-regenerating health / heart / life / energy type of system for accessing content such as levels. The resource will regenerate in real world time as the player leaves the app running or has it closed. Vita supports as many resources as you want to have in your game so that you can have some resources which recharge quickly and other more special ones which recharge slowly.

## Installation
You can use Vita in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

	https://github.com/subsoap/vita/archive/master.zip

Once added, you must require the main Lua module in scripts via

```
local vita = require("vita.vita")
```

## Tips
Some games use energy. Some use hearts. Which should you use? Generally an energy system is better because it allows you to price events in different energy amounts while users may not like that events cost multiple hearts. But some games do not need that price flexibility and so can use a simple heart system where one heart is one attempt at a level.

Generally if you use a heart system you only remove a heart if they fail an attempt (and thus usually have a lower number of total hearts). But with an energy system you remove the energy with every attempt no matter if they win or lose.