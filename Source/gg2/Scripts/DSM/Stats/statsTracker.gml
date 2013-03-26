ini_open("stats.gg2")
global.statsGames=ini_read_real("Stats","Games",0)
global.statsWins=ini_read_real("Stats","Wins",0)
global.statsLosses=ini_read_real("Stats","Losses",0)
global.statsPoints=ini_read_real("Stats","Points",0)
global.statsKills=ini_read_real("Stats","Kills",0)
global.statsDeaths=ini_read_real("Stats","Deaths",0)
global.statsAssists=ini_read_real("Stats","Assists",0)
global.statsDestruction=ini_read_real("Stats","Destruction",0)
global.statsCaps=ini_read_real("Stats","Caps",0)
global.statsDefences=ini_read_real("Stats","Defences",0)
global.statsInvulns=ini_read_real("Stats","Invulns",0)
global.statsHealing=ini_read_real("Stats","Healing",0)
global.statsStabs=ini_read_real("Stats","Stabs",0)
global.statsShotsHit=ini_read_real("Stats","ShotsHit",0)
global.statsShotsMissed=ini_read_real("Stats","ShotsMissed",0)
/*The next ones are for more specfic kill stats.
global.statsKillsAsScout=ini_read_real("Stats","ScoutKills",0)
global.statsKillsAsPyro=ini_read_real("Stats","PyroKills",0)
global.statsKillsAsSoldier=ini_read_real("Stats","SoldierKills",0)
global.statsKillsAsHeavy=ini_read_real("Stats","HeavyKills",0)
global.statsKillsAsDemoman=ini_read_real("Stats","DemomanKills",0)
global.statsKillsAsMedic=ini_read_real("Stats","MedicKills",0)
global.statsKillsAsEngie=ini_read_real("Stats","EngieKills",0)
global.statsKillsAsSpy=ini_read_real("Stats","SpyKills",0)
global.statsKillsAsSniper=ini_read_real("Stats","SniperKills",0)
global.statsKillsAsQuote=ini_read_real("Stats","QuoteKills",0)*/

ini_write_real("Stats","Games",global.statsGames)
ini_write_real("Stats","Wins",global.statsWins)
ini_write_real("Stats","Losses",global.statsLosses)
ini_write_real("Stats","Points",global.statsPoints)
ini_write_real("Stats","Kills",global.statsKills)
ini_write_real("Stats","Deaths",global.statsDeaths)
ini_write_real("Stats","Assists",global.statsAssists)
ini_write_real("Stats","Destruction",global.statsDestruction)
ini_write_real("Stats","Caps",global.statsCaps)
ini_write_real("Stats","Defences",global.statsDefences)
ini_write_real("Stats","Invulns",global.statsInvulns)
ini_write_real("Stats","Healing",global.statsHealing)
ini_write_real("Stats","Stabs",global.statsStabs)
ini_write_real("Stats","ShotsHit",global.statsShotsHit)
ini_write_real("Stats","ShotsMissed",global.statsShotsMissed)
/*The next ones are for more specfic kill stats.
ini_write_real("Stats","ScoutKills",global.statsKillsAsScout)
ini_write_real("Stats","PyroKills",global.statsKillsAsPyro)
ini_write_real("Stats","SoldierKills",global.statsKillsAsSoldier)
ini_write_real("Stats","HeavyKills",global.statsKillsAsHeavy)
ini_write_real("Stats","DemomanKills",global.statsKillsAsDemoman)
ini_write_real("Stats","MedicKills",global.statsKillsAsMedic)
ini_write_real("Stats","EngieKills",global.statsKillsAsEngie)
ini_write_real("Stats","SpyKills",global.statsKillsAsSpy)
ini_write_real("Stats","SniperKills",global.statsKillsAsSniper)
ini_write_real("Stats","QuoteKills",global.statsKillsAsQuote)*/
ini_close()

global.statsMainM=0 
global.statsKillsM=0
global.accuracy=0
