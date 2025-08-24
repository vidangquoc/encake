app.factory 'soundHandler', [ '$injector', ($injector)->
  
  serverLogger = $injector.get('serverLogger')
  
  class SoundHandler
  
    playing_sound_key: null
    
    options: {}
    
    setup: (options = {}) ->  
      
      @options = options
      
      soundManager.setup
      
        url: @options.swf_files_path
        
        debugMode: false
        
        flashVersion: 9
        
        onready: => serverLogger('SoundManager2: Sound is not supported') if not soundManager.supported()            
    
    play_sound: (sound, callback = null) ->
      
      if @_sound_registered(sound)
        
        soundManager.stop(@playing_sound_key) if @playing_sound_key?       
        
        soundManager.getSoundById(@_sound_key(sound))?.play(volume: 100)
        
        @playing_sound_key = @_sound_key(sound)
        
        callback() if callback?
        
      else
        
        @register_sound(sound, true, callback)
    
    register_sound: (sound, play = false, callback = null) ->
      
      return if @_sound_registered(sound)
      
      soundManager.createSound
              
        id: @_sound_key(sound)
        
        url: @options.sound_path.replace('(sound_id)', sound.id).replace('(version)', Date.parse(sound.updated_at)/1000) + '.mp3'
        
        autoLoad: true
        
        autoPlay: false
        
        onload: => @play_sound(sound, callback) if play
        
    release_all_sounds: (stop_playing_sound = false)-> #do nothing
        
    _sound_key: (sound) -> sound.id
      
    _sound_registered: (sound)-> soundManager.getSoundById(@_sound_key(sound))?    
    
  new SoundHandler()
  
]  