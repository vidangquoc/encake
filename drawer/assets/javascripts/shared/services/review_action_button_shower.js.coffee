'use strict'

app.factory 'reviewActionButtonShower', ->
  
  class ReviewActionButtonShower
    
    get: (stage, skill, is_reminding, is_private_point, is_mastered, is_first_listening, has_sound, has_example_sound) ->
      
      shown_buttons = {}
      
      if stage == 'asking'
        
        if skill == 'interpret'
          shown_buttons['edit'] = true if is_private_point && is_reminding
          shown_buttons['view_image'] = true if is_reminding
        else if skill == 'reverse_interpret'
          shown_buttons['play_sound'] = true if is_reminding && has_sound
          shown_buttons['edit'] = true if is_private_point && is_reminding
          shown_buttons['view_image'] = true if is_reminding
        else if skill == 'grammar'
          shown_buttons['view_lesson'] = true if ! is_private_point
        else if skill == 'sentence_dictate'
          shown_buttons['speech'] = true
          shown_buttons['play_sound'] = true if is_reminding && has_example_sound
          shown_buttons['edit'] = true if is_private_point
          shown_buttons['view_lesson'] = true if ! is_private_point
        else if skill == 'sentence_reverse_interpret'
          shown_buttons['speech'] = true
          shown_buttons['play_sound'] = true if is_reminding && has_example_sound
          shown_buttons['view_lesson'] = true if ! is_private_point
          shown_buttons['edit'] = true if is_private_point && is_reminding
        else if skill == 'sentence_listen_and_repeat'
          if !is_first_listening
            shown_buttons['play_sound'] = true if has_example_sound
            shown_buttons['speech'] = true
            shown_buttons['edit'] = true if is_private_point && is_reminding
            shown_buttons['view_lesson'] = true if ! is_private_point
          
      else
        
        if skill == 'interpret'
          shown_buttons['play_sound'] = true if has_sound
          shown_buttons['view_image'] = true
          shown_buttons['view_example'] = true
          shown_buttons['edit'] = true if is_private_point
        else if skill == 'reverse_interpret'
          shown_buttons['play_sound'] = true if has_sound
          shown_buttons['view_image'] = true
          shown_buttons['view_example'] = true
          shown_buttons['edit'] = true if is_private_point
        else if skill == 'grammar'
          shown_buttons['view_lesson'] = true if ! is_private_point
        else if skill == 'sentence_reverse_interpret'
          shown_buttons['play_sound'] = true if has_example_sound
          shown_buttons['edit'] = true if is_private_point
          shown_buttons['view_lesson'] = true if ! is_private_point
        else if skill == 'sentence_listen_and_repeat'
          shown_buttons['play_sound'] = true if has_example_sound
          shown_buttons['edit'] = true if is_private_point
          shown_buttons['view_lesson'] = true if ! is_private_point
      
      if !is_first_listening
        shown_buttons['master'] = true if ! is_mastered
        shown_buttons['umaster'] = true if is_mastered
      
      shown_buttons
      
  new ReviewActionButtonShower()