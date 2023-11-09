import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

local musicPlayer = pd.sound.fileplayer.new("music")

local soundEffectPlayer = pd.sound.sampleplayer.new("soundEffect.wav")
local isRecording = false

local synthPlayer = pd.sound.synth.new(pd.sound.kWaveSquare)
synthPlayer:setADSR(0,0.2,1,0.5)

local lfo = pd.sound.lfo.new(pd.sound.kWaveSine)
lfo:setRate(2)

--synthPlayer:setFrequencyMod(lfo)

local chestOpen = pd.sound.track.new()
chestOpen:addNote(1,"Bb3", 2)
chestOpen:addNote(5,"C4", 1)
chestOpen:addNote(6,"G4", 1)
chestOpen:addNote(7,"Bb4", 1)
chestOpen:setInstrument(synthPlayer:copy())

local chestSequence = pd.sound.sequence.new()
chestSequence:addTrack(chestOpen)
chestSequence:setTempo(10)

local musicSequence = pd.sound.sequence.new("midiFile.mid")
local track1 = musicSequence:getTrackAtIndex(2)
local track2 = musicSequence:getTrackAtIndex(3)
track1:setInstrument(synthPlayer:copy())
track2:setInstrument(pd.sound.synth.new())
musicSequence:setTrackAtIndex(2,track1)
musicSequence:setTrackAtIndex(3,track2)


function pd.update()
	--Trigger music with A button
    if pd.buttonJustPressed(pd.kButtonA) then
        musicSequence:play()
        musicSequence:setLoops(0)
    end

    --Trigger sound effect with B button
    if pd.buttonJustPressed(pd.kButtonB) then
        soundEffectPlayer:setLoopCallback(FinishedPlayingSoundEffect)
        soundEffectPlayer:play(0)
    end
    if pd.buttonJustReleased(pd.kButtonB) then
        soundEffectPlayer:stop()
    end

    --Trigger recording with Right Arrow
    if pd.buttonJustPressed(pd.kButtonRight) then
        --Start recording
        isRecording = true
        pd.sound.micinput.startListening()
        local buffer = pd.sound.sample.new(5, pd.sound.kFormat16bitMono)
        pd.sound.micinput.recordToSample(buffer, FinishedRecordingMicrophone)
    end
    if pd.buttonJustReleased(pd.kButtonRight) then
        --Stop recording and load recording into SoundEffectPlayer
        pd.sound.micinput.stopRecording()
    end

    --Adjust music speed with up/down
    if pd.buttonIsPressed(pd.kButtonUp) then
        musicPlayer:setRate(1.5)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        musicPlayer:setRate(0.5)
    else
        musicPlayer:setRate(1)
    end

    --trigger synth with left arrow
    if pd.buttonJustPressed(pd.kButtonLeft) then
        synthPlayer:playMIDINote("Bb3")
    end
    if pd.buttonJustReleased(pd.kButtonLeft) then
        synthPlayer:noteOff()
    end

    --Visual
    gfx.clear()
    if isRecording then
        gfx.fillCircleAtPoint(200,120,10)
    elseif musicPlayer:isPlaying() or soundEffectPlayer:isPlaying() then
        gfx.fillTriangle(190,110,210,120,190,130)
    else
        gfx.fillRect(190,110,20,20)
    end

    --visualize microphone level
    gfx.fillRect(10,200,10,-pd.sound.micinput.getLevel()*200)
end

function FinishedPlayingSoundEffect()
    print("Finished playing sound effect")
end

function FinishedRecordingMicrophone(recording)
    isRecording = false
    pd.sound.micinput.stopListening()
    soundEffectPlayer:setSample(recording)
end