require 'rails_helper'

RSpec.describe PointImage, type: :model do
  it { is_expected.to validate_presence_of :point_id }
  it { is_expected.to validate_presence_of :image }
end
