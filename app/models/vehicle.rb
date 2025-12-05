class Vehicle < ApplicationRecord
  belongs_to :manufacturer
  has_many_attached :images
end
