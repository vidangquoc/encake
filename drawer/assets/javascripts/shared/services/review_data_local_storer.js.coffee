app.factory 'reviewDataStorer', ['$injector', ($injector) ->
  
  $filter       = $injector.get('$filter')
  $rootScope    = $injector.get('$rootScope')
  serverLogger  = $injector.get('serverLogger')
  localStorageService   = $injector.get('localStorageService')
  
  serverLogger.log("Local Storage is not supported") if ! localStorageService.isSupported
  
  class ReviewDataStorer
  
    store: (states, data) ->
      
      if @local_storage_supported()
        
        localStorageService.set(@storage_key(), {valid_date: @format_date(new Date()), states: states, review_data: data})
        
    restore: ->  
    
      if @local_storage_supported()
        
        localStorageService.get(@storage_key())
        
    review_data_available: ->
      
      if @local_storage_supported()
        
        stored_data = localStorageService.get(@storage_key())
        
        stored_data?.valid_date? && stored_data.valid_date == @format_date( new Date() ) && stored_data.review_data.point_ids?.length > 0
      
      else
        
        false
        
    clear: -> localStorageService.remove(@storage_key(), null)
        
    local_storage_supported: -> localStorageService.isSupported
    
    storage_key: -> 'review_data_of_user_' + $rootScope.current_user.id
    
    format_date: (date)-> $filter('date')(date, 'MM/dd/yyyy')
    
  new ReviewDataStorer()
  
]  