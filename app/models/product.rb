# the model for product
class Product < ActiveRecord::Base
  has_and_belongs_to_many :lists
  belongs_to :ubication

  def to_s
    self.name
  end
end
