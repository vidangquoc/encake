app.factory 'pointIllustratingImagesShowerHelper', [ 'urlHelper', (urlHelper) ->
  
  class PointIllustratingImagesShowerHelper
  
    init: (scope, options) ->
      
      @scope = scope
      
      @watch()
      @bind_window_resize()
      @scope.next = => @next()
      @scope.previous = => @previous()
    
    watch: -> 
      
      @scope.$watch 'point', (point) =>
        
         if point? && point.images?.length > 0
        
            @scope.current_index = 0
            
            @scope.image_url_key = @specify_image_url_key()
            
            @scope.current_image_url = @current_image_url()
            
            @preload_images()
    
    next: ->
      
      @scope.current_index = @scope.current_index + 1
      
      if @scope.current_index > @scope.point.images.length - 1

        @scope.current_index = @scope.point.images.length - 1
      
      @scope.current_image_url = @current_image_url()
          
    previous: ->
      
      @scope.current_index = @scope.current_index - 1
      
      if @scope.current_index < 0
        
        @scope.current_index = 0
      
      @scope.current_image_url = @current_image_url()
    
    current_image_url: ->
      
      @scope.point.images[@scope.current_index][@scope.image_url_key]
    
    specify_image_url_key: ->
      
      doc_height = $(document).height()
      doc_width = $(document).width()
      
      if doc_height > 900 && doc_width > 550
        'big_url'
      else if doc_height > 750 && doc_width > 450
        'medium_url'
      else
        'small_url'
      
    preload_images: ->
      
      if @scope.point?
        
        for image in @scope.point.images
          
          urlHelper.load_image(image[@scope.image_url_key])
  
    bind_window_resize: ->
      
      $(window).on 'resize.review load.review', =>
      
        @scope.$apply =>
        
          @scope.image_url_key = @specify_image_url_key()
          
          @scope.current_image_url = @current_image_url()
          
          @preload_images()
          
      @scope.$on "$destroy", -> $(window).off('resize.review')
  
  new PointIllustratingImagesShowerHelper()
          
]          