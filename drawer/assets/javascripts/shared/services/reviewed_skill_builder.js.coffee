'use strict'

app.factory 'reviewedSkillBuilder', [ 'serverLogger', (serverLogger) ->
  
  class ReviewedSkillBuilder
  
    build: (points) ->
      
      points_with_reviewed_skill = []
      
      for point in points
        
        if point.reviewed_skill? && point.reviewed_skill #reviewed
          
          if(point.reviewed_skill == 'verbal')
            
            if point.is_valid? && point.is_valid 
              
              if point.effectively_reviewed_times < 2
                
                point.reviewed_skill = 'sentence_dictate'
                
              else
                
                point.reviewed_skill = 'sentence_listen_and_repeat'
                
            else
              
              if point.main_example?
              
                point.reviewed_skill = 'sentence_dictate'
                
              else
                
                point.reviewed_skill = 'interpret'
          
          points_with_reviewed_skill.push(point)
          
        else #new
          
          points_with_reviewed_skill.push @clone_point_for_skill(point, 'interpret')
          
          if point.is_valid
            
            points_with_reviewed_skill.push @clone_point_for_skill(point, 'grammar') if point.question?
          
      points_groupped_by_skill = []
      
      for reviewed_skill in ['interpret', 'grammar', 'sentence_dictate', 'sentence_listen_and_repeat']    
        
        for point in points_with_reviewed_skill
          
          points_groupped_by_skill.push(point) if point.reviewed_skill == reviewed_skill
                
      points_groupped_by_skill


    build_for_lesson_preview: (points, skills_to_build) ->
      
      if skills_to_build == 'all'
        
        skills_to_build = ['interpret', 'grammar', 'sentence_dictate', 'sentence_listen_and_repeat']
      
      else
         
        skills_to_build =  ( skill.replace(/^ +/).replace(/ $/) for skill in skills_to_build.split(',') )
      
      points_with_reviewed_skill = []
      
      for point in points                            
        
        for skill in skills_to_build
          
          if skill == 'interpret'
            
            points_with_reviewed_skill.push @clone_point_for_skill(point, 'interpret')
            
          if skill == 'grammar' && point.question?
        
            points_with_reviewed_skill.push @clone_point_for_skill(point, 'grammar')
          
          if skill == 'sentence_dictate' && point.main_example?
            
            points_with_reviewed_skill.push @clone_point_for_skill(point, 'sentence_dictate')
          
          if skill == 'sentence_listen_and_repeat' && point.main_example?
            
            points_with_reviewed_skill.push @clone_point_for_skill(point, 'sentence_listen_and_repeat')
            
      points_groupped_by_skill = []
      
      for reviewed_skill in ['interpret', 'grammar', 'sentence_listen_and_repeat', 'sentence_dictate']
      
        for point in points_with_reviewed_skill
          
          points_groupped_by_skill.push(point) if point.reviewed_skill == reviewed_skill
      
      points_groupped_by_skill
    

    clone_point_for_skill: (point, skill) ->
      
      point = JSON.parse(JSON.stringify(point))
      
      point.reviewed_skill = skill
      
      point
        
  new ReviewedSkillBuilder()
  
]