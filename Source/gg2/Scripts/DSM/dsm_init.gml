ini_open("DSM.ini")
global.randomiseMapRotation=ini_read_real("Settings","RandomiseMapRotation",0)
global.drawIntelArrows=ini_read_real("Settings","DrawIntelArrows",1)
global.hpBarText=ini_read_real("Settings","HPBarText",1)
global.ammoBar=ini_read_real("Settings","AmmoBar",1)
global.generatorStab=ini_read_real("Settings","GeneratorStab",1)
global.textHighlightColour=ini_read_real("Settings","TextHighlightColour",0)
global.recoilAnimations=ini_read_real("Settings","RecoilAnimations",1)
global.showKillLog=ini_read_real("Settings","ShowKillLog",1)
global.recordingEnabled=ini_read_real("Settings","RecordingEnabled",0)
global.healingArrow=ini_read_real("Settings","HealingArrow",1)

global.alreadyWroteStats=0
global.serverGenStab=0

ini_write_real("Settings","RandomiseMapRotation",global.randomiseMapRotation)
ini_write_real("Settings","DrawIntelArrows",global.drawIntelArrows)
ini_write_real("Settings","HPBarText",global.hpBarText)
ini_write_real("Settings","AmmoBar",global.ammoBar)
ini_write_real("Settings","GeneratorStab",global.generatorStab)
ini_write_real("Settings","TextHighlightColour",global.textHighlightColour)
ini_write_real("Settings","RecoilAnimations",global.recoilAnimations)
ini_write_real("Settings","ShowKillLog",global.showKillLog)
ini_write_real("Settings","RecordingEnabled",global.recordingEnabled)
ini_write_real("Settings","HealingArrow",global.healingArrow)
ini_close()

statsTracker()

if(!directory_exists(working_directory + "\Replays")) directory_create(working_directory + "\Replays")
global.replayBuffer = buffer_create() //Used by the server to save the replay and by the client to load it.
global.isPlayingReplay=0
global.replaySpeed=1
global.justEnabledRecording=0 //Used to know if the recording just began, to save the first bytes.
