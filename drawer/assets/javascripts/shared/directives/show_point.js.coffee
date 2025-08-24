app.directive 'showPoint',[ ->
  
    restrict: 'A'
    
    scope:
      
      point: '=showPoint'
    
    link: (scope, element, attrs) ->
      
      scope.$watch 'point', (point) ->
        
        if point?
          
          html = point
          
          if point.indexOf(' ') == -1
            
            html = "<span class='point-container'>"
            
            groups = point.split('\.\.')
            
            j = 0
            
            for group in groups
              
              group_class =  if j%2 == 0 then 'point-part-group' else 'point-part-group-alternative'
              
              html += "<span class='" + group_class + "'>"
              
              splits = group.split('\.')
            
              i = 0
              
              for split in splits
                
                part_class =  if i%2 == 0 then 'point-part' else 'point-part-alternative'
                
                html += "<span class='" + part_class + "'>" + split + "</span>"
                
                i += 1
              
              html += "</span>"
                
              j += 1  
            
            #splits = point.split('\.')
            #
            #i = 0
            #
            #for split in splits
            #  
            #  html_class =  if i%2 == 0 then 'point-part' else 'point-part-alternative'
            #  
            #  html += "<span class='" + html_class + "'>" + split + "</span>"
            #  
            #  i += 1
            
            html += "</span>"  
            
          element.html html

]