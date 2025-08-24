class ApiConstraints
  
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || (req.headers['HTTP_API_VERSION'] || req.headers['API_VERSION']).to_i == @version
  end
  
end