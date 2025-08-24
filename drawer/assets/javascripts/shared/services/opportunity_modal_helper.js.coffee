app.factory 'opportunityModalHelper', [ '$injector', ($injector)->
  
  httpApi = $injector.get('httpApi')
  $timeout = $injector.get('$timeout')
  
  class OpportunityModalHelper
  
    init: (scope, options) ->
      
      @scope = scope
      @scope.exchanges = {}
      @options = options
      
      @watch()
      
      @scope.ignore_opportunity = => @ignore_opportunity()
      @scope.start_taking_opportunity = => @scope.stage = 'taking'
      @scope.update_possibility = => @update_possibility()
      @scope.take_opportunity = => @take_opportunity()
      @scope.close_modal = => @scope.visible = false
    
    watch: -> 
      
      @scope.$watch 'opportunity', =>
        
        if @scope.opportunity?
          
          @scope.possibility = @scope.opportunity.min_opportunity_possibility
          
          @scope.exchanges.number_of_used_lucky_stars='0'
          
          star_numbers = []
          
          index = 0
          
          max_star_number = @scope.opportunity.max_opportunity_possibility - @scope.opportunity.min_opportunity_possibility
          
          max_star_number = @scope.opportunity.number_of_lucky_stars if max_star_number > @scope.opportunity.number_of_lucky_stars
          
          while true
            
            star_number = index*10
            
            break if( star_number > max_star_number )
              
            star_numbers.push(star_number)
            
            index += 1
            
          if star_numbers.indexOf(max_star_number) == -1
            
            star_numbers.push max_star_number
         
          @scope.star_numbers = star_numbers
      
      @scope.$watch 'visible', (value) =>
      
        if value == true
          
          @scope.stage = 'init'
          
          @options.show_modal()
          
        else
          
          @options.hide_modal()
      
      
    ignore_opportunity: ->
      
      @options.hide_modal()
        
      httpApi.put( "opportunities/" + @scope.opportunity.id + "/ignore" )
      
    update_possibility: ->
      
      @scope.possibility = @scope.opportunity.min_opportunity_possibility + parseInt(@scope.exchanges.number_of_used_lucky_stars)
      
      @scope.possibility = if @scope.possibility > @scope.opportunity.max_opportunity_possibility then @scope.opportunity.max_opportunity_possibility else @scope.possibility
    
    take_opportunity: ->
      
      @scope.stage = 'processing'
      
      $timeout @send_take_request_to_server, 5000
          
    send_take_request_to_server: =>
      
      httpApi.put( "opportunities/" + @scope.opportunity.id + "/take", number_of_used_lucky_stars:  @scope.exchanges.number_of_used_lucky_stars).then (response) =>
        
        @scope.is_won = response.data.is_won
        
        @scope.stage = 'finished'
        
      , =>
        
        @options.hide_modal()
    
    on_modal_show: (attrs) ->
      
      @scope.$apply => @scope.visible = true
      
      @scope.$apply(@scope.after_show) if attrs.afterShow?
      
    on_modal_hide: (attrs) ->
      
      @scope.$apply => @scope.visible = false
      
      @scope.$apply(@scope.before_hide) if attrs.beforeHide?
      
  
  new OpportunityModalHelper()
  
]  