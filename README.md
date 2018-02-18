![Vita](vita_logo.png)

# Vita
A generic energy / life system for Defold

## Installation
You can use Vita in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

	https://github.com/subsoap/vita/archive/master.zip

Once added, you must require the main Lua module in scripts via

```
local vita = require("vita.vita")
```

## Tips
Some games use energy. Some use hearts. Which should you use? Generally an energy system is better because it allows you to price events in different energy amounts while users may not like that events cost multiple hearts. But some games doesn't need that price flexibility and so can use a simple heart system where one heart is one attempt at a level.