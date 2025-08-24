class Article < ActiveRecord::Base
  strip_attributes collapse_spaces: true
end
