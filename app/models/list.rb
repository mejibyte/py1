# the model for list in the database
class List < ActiveRecord::Base
  belongs_to :persona
  has_and_belongs_to_many :products
end
