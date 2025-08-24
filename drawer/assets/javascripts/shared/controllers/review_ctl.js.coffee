app.controller 'ReviewCtrl', ['$scope','$injector', ($scope, $injector) ->
  
  $timeout        = $injector.get('$timeout')
  $filter         = $injector.get('$filter')
  $state          = $injector.get('$state')
  $stateParams    = $injector.get('$stateParams')
  reviewTracker   = $injector.get('reviewTracker')
  soundHandler    = $injector.get('soundHandler')
  serverLogger    = $injector.get('serverLogger')
  httpApi         = $injector.get('httpApi')
  Constants       = $injector.get('Constants')
  platform        = $injector.get('platform')
  invalidPointDetector  = $injector.get('invalidPointDetector')
  reviewDataStorer      = $injector.get('reviewDataStorer')
  reviewedSkillBuilder = $injector.get('reviewedSkillBuilder')
  exampleAlternativeParser = $injector.get('exampleAlternativeParser')
  reviewActionButtonShower = $injector.get('reviewActionButtonShower')
  
  previewing_lesson = $stateParams.lesson_id?
  
  $scope.review = {}
  
  $scope.review.feedback = 'none'
  
  $scope.review.asserting_questions = {}
  
  $scope.states = {}
  
  $scope.states.spelling = '' 
  
  $scope.states.forced_mode = 'none'
    
  $scope.states.mode  = null

  $scope.review_active = false;
  
  $scope.review.people = [{id: 1, name: 'Vi'}, {id: 2, name: 'Cam'}]
  
  init_page = ->
    
    #show_new_level({position: 1000})
    
    #show_teaser_updater({action_id: 1, friend_names:['Vi', 'Cam']})
    
    soundHandler.setup
    
      sound_path: Constants.api_endpoint + 'sounds/(sound_id)/(version)'
          
    if review_data_available_in_local_storage() && !$stateParams.reload?
      
      restore_review_data()
            
    else
      
      if previewing_lesson
        load_points_of_lesson_for_previewing()
      else
        load_review_data_from_server()
    
    set_up_watches_and_subscribers()
    
    httpApi.get('points/types').then (response) -> $scope.point_types = response.data
    
  set_up_watches_and_subscribers = ->
    
    $scope.$watch "states", ->
      if $scope.review_active
        store_review_data()
    , true
    
    $scope.$watch "current_point", (point)->
      if(point)
        $scope.review.tracked_data = {skill: point.reviewed_skill, point_id: point.id}
      else
        $scope.review.tracked_data = {}
        
  load_review_data_from_server = (forced_mode = null)->
    
    forced_mode = if forced_mode? then forced_mode else $scope.states.forced_mode
    
    $scope.review_active = false;
    
    httpApi.get('/reviews/init_review', params: {forced_mode: forced_mode}).then (response)->
      
      $scope.review.level_data = {around_levels: response.data.around_levels, current_score: response.data.score}
      
      $scope.due_points = response.data.due_points
      
      $scope.total_points = response.data.total_points
      
      $scope.review_active = true
      
      if response.data.points.length > 0
        
        init_review({points: response.data.points})
        
        $scope.states.forced_mode = forced_mode
        
        $scope.states.mode = response.data.mode
      
      else
        
        handle_no_more_points(forced_mode)
      
  load_points_of_lesson_for_previewing = ->
    
    url = "/reviews/load_points_of_lesson_for_previewing?lesson_id=" + $stateParams.lesson_id
    
    httpApi.get(url).then (response)->
      
      $scope.states.mode = response.data.mode
      
      $scope.review.level_data = {around_levels: response.data.around_levels, current_score: response.data.score}
      
      $scope.due_points = response.data.due_points
      
      $scope.total_points = response.data.total_points
      
      $scope.review_active = true
      
      init_review({points: response.data.points})
      
  init_review = (data, points_restored = false) ->
    
    register_sounds(data.points)
    
    if previewing_lesson
      
      data.points = reviewedSkillBuilder.build_for_lesson_preview(data.points, $stateParams.skills)
      
    else
     
      data.points = reviewedSkillBuilder.build(data.points)
    
    reviewTracker.reset(data, change_phase)
            
    $scope.review.has_points = 'yes'
    
    $scope.enable_window_keyup()
    
    $scope.current_point = null
    
    if points_restored
      
      $scope.current_point = reviewTracker.current_point()
      
    else
      
      $scope.states.mastered_skills = {}
      
      $scope.review.phase_ended = false
      
      display_point reviewTracker.current_point()
  
  prepare_reminded_times = ->

    reminded_times = reviewTracker.reminded_times()
    
    for item in reminded_times
      
      is_mastered = false
      
      for mastered_skill of $scope.states.mastered_skills
        
        point_id_and_skill = mastered_skill.split(':')
        
        if item.point_id == parseInt(point_id_and_skill[0]) && item.skill_symbol == point_id_and_skill[1]
          
          is_mastered = true
          
      item.is_mastered = is_mastered
    
    reminded_times
    
  finish_review =->
    
    return if reviewTracker.points.length == 0
    
    $scope.review_active = false
    
    $scope.disable_window_keyup()
    
    httpApi.post( '/reviews/process_review', {reminded_times: prepare_reminded_times(), forced_mode: $scope.states.forced_mode})
    
    .then (response) =>
      
      response = response.data
      
      $scope.states.mode = response.mode
      
      $scope.due_points = response.due_points
      
      $scope.total_points += response.learnt_points if response.learnt_points?
                  
      if response.points.length > 0
        
        init_review(points: response.points)
        
      else #no more point
        
        handle_no_more_points($scope.states.forced_mode)
          
      $scope.review_active = true
        
      process_result = response.process_review_result
      
      $scope.review.level_data.current_score = response.score
      
      if process_result.level_changed != 0
        
        $scope.review.level_data.around_levels = response.around_levels
      
      if process_result.opportunity?
        
        show_opportunity(process_result.opportunity)
      
      else if process_result.overcome_friends.length > 0 # user overcomes friends
        
        $scope.teaser_data = {action_id: process_result.action_id, friend_names: process_result.overcome_friends}
        
        show_teaser_updater()
          
      else if process_result.level_changed == 1 # user reaches new level
        
        show_new_level(response.around_levels[1])
        
      else if process_result.number_of_rewarded_lucky_stars > 0
        
        show_rewarded_lucky_stars(process_result.number_of_rewarded_lucky_stars, process_result.lucky_star_image)
        
      else
        
        score_change = process_result.score_change
        
        if score_change  > 0
        
          $scope.review.added_score = score_change
          
          show_added_score();
  
  $scope.show_search_result = (points)->
    
    $scope.review.searched_points = points
    
    show_searched_points()
    
    detect_linked_skills_of_example_and_mark_as_reminded(points)
  
  $scope.hide_feedback = ->
    
    $scope.enable_window_keyup()
    
    $scope.review.feedback = 'none'
  
  show_feedback = (feedback)->
    
    $scope.disable_window_keyup()
    
    $scope.review.feedback = feedback
    
  #show_teaser_updater = -> $scope.review.teaser_updater_shown = true
  
  show_teaser_updater = (data)->
    
    $scope.teaser_data = data
    
    show_feedback('teaser')
    
  show_new_level = (level)->
    
    $scope.new_level = level
    
    show_feedback('new_level')
  
  show_added_score = -> $scope.review.added_score_shown = Math.random()*10000000
  
  show_searched_points = -> $scope.review.searched_points_shown = true
  
  show_opportunity = (opportunity) ->
    
    $scope.review.opportunity = opportunity
    
    $scope.review.opportunity_shown = true
  
  show_rewarded_lucky_stars = (number_of_rewarded_lucky_stars, lucky_star_image) ->
    
    $scope.review.number_of_rewarded_lucky_stars_shown = true
    
    $scope.review.number_of_rewarded_lucky_stars = number_of_rewarded_lucky_stars
    
    $scope.review.lucky_star_image = lucky_star_image
  
  #show_rewarded_lucky_stars(20, 'assets/lucky_star.png')
    
  #show_opportunity({
  #  id: 3,
  #  user_id: 1,
  #  badge_type_id: 1,
  #  is_taken: false,
  #  number_of_lucky_stars: 100,
  #  min_opportunity_possibility: 10,
  #  max_opportunity_possibility: 90,
  #  processing_image: '/assets/opportunity_processing.gif',
  #  badge_type: {
  #    id: 1,
  #    badge_type: 'warrior',
  #    name: 'Chiến Binh Đồng',
  #    number_of_efforts_to_get: 60,
  #    image_url: "/system/uploads/badge_type/image/81/1491885256_warrior.png"
  #  },
  #  #next_badge_type: null,
  #  next_badge_type: {
  #    id: 1,
  #    badge_type: 'diligent',
  #    name: 'Chiến Binh Bạc',
  #    number_of_efforts_to_get: 120,
  #  }
  #})
  
  $scope.show_opportunity_modal = -> $scope.review.opportunity_shown = true
    
  detect_linked_skills_of_example_and_mark_as_reminded = (in_points)->
    
    example_id = $scope.current_point?.main_example?.id
    
    point_ids = (point.id for point in in_points)
    
    if example_id? && point_ids.length > 0
      
      httpApi.post('/reviews/detect_linked_skills_of_example_and_mark_as_reminded', example_id: example_id, point_ids: point_ids)
  
  handle_no_more_points = (forced_mode) ->
    
    clear_review_data()
    
    if forced_mode == 'none'
      $scope.review.has_points = 'no'
    else if forced_mode == 'reviewing'
      $scope.review.has_points = 'no_review'
    else
      $scope.review.has_points = 'no_new'
  
  $scope.refresh = -> #this is only available on mobile
    
    $scope.$broadcast('scroll.refreshComplete')
    
    load_review_data_from_server()
  
  $scope.force_mode = (forced_mode) -> load_review_data_from_server(forced_mode)
    
  $scope.next_point = (is_right = true)->
    
    return if check_first_listening()
      
    if $scope.states.current_stage == 'asking'
      
      if $scope.current_point.reviewed_skill != 'grammar' && $scope.current_point.reviewed_skill != 'sentence_listen_and_repeat' 
        play_sound() 
        
      if $scope.current_point.reviewed_skill == 'grammar'
        
        if($scope.current_point.question.question_type == 'choosing')
          set_correct_grammar_answer_of_choosing_type()
        else
          set_correct_grammar_answer_of_filling_in_type()
      
      if $scope.states.reminded || $scope.current_point.reviewed_skill == 'sentence_dictate'
        
        if $scope.current_point.reviewed_skill == 'sentence_dictate'
          
          play_sound()
        
        display_point reviewTracker.next_point()
        
      else
        
        $scope.states.current_stage = 'asserting'
        
        specify_shown_action_buttons()
    
    else #current_stage is asserting
      
      if !is_right
        
        reviewTracker.record_reminding()
      
      display_point reviewTracker.next_point()
    
  next_point_without_checking = ->
    
    display_point reviewTracker.next_point()
      
  $scope.previous_point = ->
    
    $scope.review.phase_ended = false
    
    display_point reviewTracker.previous_point()
    
  $scope.remind_point =->
    
    return if check_first_listening()
    
    $scope.states.show_reminding = true
    
    $scope.states.example_alternatives = parse_example_alternatives()
      
    if $scope.current_point.reviewed_skill == 'grammar'
      
      if($scope.current_point.question.question_type == 'choosing')
      
        set_correct_grammar_answer_of_choosing_type()
        
      else
        
        set_correct_grammar_answer_of_filling_in_type()
      
    reviewTracker.record_reminding()
    
    $scope.states.reminded = true
    
    specify_shown_action_buttons()
    
    if ['interpret', 'reverse_interpret', 'sentence_dictate', 'sentence_reverse_interpret', 'sentence_listen_and_repeat'].indexOf($scope.current_point.reviewed_skill) != -1
    
      play_sound() 
  
  $scope.remind_point_or_wrong_answer_assert = ->
    
    if $scope.states.current_stage == 'asking'
      
      $scope.remind_point()
      
    else
      
      $scope.next_point(false)
  
  $scope.mark_as_mastered = ->
    
    $scope.states.mastered_skills[$scope.current_point.id + ":" + $scope.current_point.reviewed_skill] = true
    
    reviewTracker.clear_reminding()
    
    next_point_without_checking()
  
  $scope.mark_as_unmastered = ->
    
    delete $scope.states.mastered_skills[$scope.current_point.id + ":" + $scope.current_point.reviewed_skill]
  
  $scope.view_example = ->
    
    $scope.states.view_example = true
  
  $scope.on_window_size_change = (window_width, window_height)->
    
    if window_height > 700 && window_width > 500
      
      $scope.review.window_suitable_for_action_buttons = true
      
    else
      
      $scope.review.window_suitable_for_action_buttons = false
  
  calculate_progress = -> $scope.states.progress = reviewTracker.progress()
    
  specify_shown_action_buttons =->
    
    stage = $scope.states.current_stage
    skill = $scope.current_point.reviewed_skill
    is_reminding = $scope.states.show_reminding
    is_private_point = $scope.current_point.is_private
    is_mastered = $scope.states.mastered_skills[$scope.current_point.id + ":" + $scope.current_point.reviewed_skill]?
    is_first_listening = $scope.states.first_listening
    has_sound = $scope.current_point.sound?.has_data
    has_example_sound = $scope.current_point.main_example?.sound?.has_data
    
    $scope.states.shown_buttons = reviewActionButtonShower.get(stage, skill, is_reminding, is_private_point, is_mastered, is_first_listening, has_sound, has_example_sound)
    
  check_first_listening = ->
    
    if $scope.states.first_listening
      
      $scope.play_sound_for_first_listening()
      
      return true
    
    else
      
      false
  
  parse_example_alternatives = ->
    
    alternatives = []
    
    if $scope.current_point.main_example?
    
      alternatives = [$scope.current_point.main_example.content]
        
      for alternative in $scope.current_point.main_example.alternatives
        
        for parsed_alternative in exampleAlternativeParser.parse(alternative.content)
          
          alternatives.push(parsed_alternative)
    
    alternatives
    
  set_correct_grammar_answer_of_choosing_type =->
    
    $scope.states.chosen_answer_id = $scope.current_point.question.right_answer_id
    
    $scope.states.answer_with_right_status_id = $scope.current_point.question.right_answer_id
    
  set_correct_grammar_answer_of_filling_in_type =->
    
    $scope.states.answer = $scope.current_point.question.answer
           
  play_sound =->
    
    if $scope.current_point.reviewed_skill != 'interpret' && $scope.current_point.reviewed_skill != 'reverse_interpret'
      soundHandler.play_sound($scope.current_point.main_example.sound) if $scope.current_point.main_example?.sound?.has_data
    else
      soundHandler.play_sound($scope.current_point.sound) if $scope.current_point.sound?.has_data
      
  $scope.play_sound_for_first_listening = ->
    
    play_sound();
    
    $scope.states.first_listening = false;
    
    specify_shown_action_buttons()
      
  $scope.play_sound = play_sound
  
  change_phase =->
    
    $scope.review.phase_ended = true
    
    finish_review() if !previewing_lesson
    
  $scope.enable_window_keyup =-> $scope.window_keyup_enabled = true
    
  $scope.disable_window_keyup =-> $scope.window_keyup_enabled = false 
  
  register_sounds = (points)->
    
    soundHandler.release_all_sounds()
    
    for point in points
        
      soundHandler.register_sound(point.sound) if point.sound?.has_data
      
      soundHandler.register_sound(point.main_example.sound) if point.main_example?.sound?.has_data
        
  display_point = (point) ->
    
    return if $scope.review.phase_ended
    
    $scope.states.first_listening = ($scope.current_point?.reviewed_skill != 'sentence_listen_and_repeat' && point.reviewed_skill == 'sentence_listen_and_repeat')
    
    reset_states()
    
    $scope.states.current_point_id = point.id

    $scope.current_point = point
    
    play_sound() if $scope.current_point.reviewed_skill == 'sentence_listen_and_repeat' && !$scope.states.first_listening
    
    calculate_progress()
    
    specify_shown_action_buttons()
    
    invalidPointDetector.detect $scope.current_point
    
  reset_states = ->
    
    $scope.states.chosen_answer_id = null
    
    $scope.states.answer_with_right_status_id = null
    
    $scope.states.current_stage = 'asking'
    
    $scope.states.reminded = false
  
    $scope.states.show_reminding = false
    
    $scope.states.recorded = null
    
    $scope.states.spelling = ''
    
    $scope.states.answer = ''
    
    $scope.states.view_example = false
    
  store_review_data = ->
    
    reviewDataStorer.store($scope.states, reviewTracker.data())
  
  clear_review_data = ->
    
    reviewDataStorer.clear()
    
  restore_review_data = ->
    
    stored_data = reviewDataStorer.restore()
    
    posted_skills = []
    
    for skill in stored_data.review_data.skills
      
      new_skill = [skill[0], skill[1]]
      
      if new_skill[1] == 'sentence_dictate' || new_skill[1] == 'sentence_reverse_interpret' || new_skill[1] == 'sentence_listen_and_repeat'
        
        new_skill[1] = 'verbal'
        
      posted_skills.push(new_skill)
      
    httpApi.post('/reviews/load_points_being_reivewed', mode: stored_data.states.mode, skills: posted_skills).then (response)->
      
      $scope.states = stored_data.states
            
      $scope.review.level_data = {around_levels: response.data.around_levels, current_score: response.data.score}
      
      $scope.total_points = response.data.total_points
      
      $scope.due_points = response.data.due_points
      
      points = response.data.points
      
      #restore reviewed state for verbal skills
      for point in points
        
        if point.reviewed_skill == 'verbal'
          
          for skill in stored_data.review_data.skills
            
            point.reviewed_skill = skill[1] if point.id == skill[0]
        
      stored_data.review_data.points = points
      
      $scope.review_active = true
      
      init_review(stored_data.review_data, true)
      
    , (response) ->
      
      load_review_data_from_server()
      
  review_data_available_in_local_storage = -> return reviewDataStorer.review_data_available()
  
  #wrap init_page in $timeout to make sure that initial scope attributes are asigned before they are used
  $timeout -> init_page()
    
]