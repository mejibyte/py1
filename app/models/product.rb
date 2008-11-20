# the model for product
class Product < ActiveRecord::Base
  has_and_belongs_to_many :lists
  belongs_to :ubication
end
