class ExamplePointLink < ActiveRecord::Base
  belongs_to :example
  belongs_to :point
end
