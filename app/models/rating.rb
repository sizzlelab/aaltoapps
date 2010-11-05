class Rating < ActiveRecord::Base
  Max = 5
  Increment = 0.5

  def self.allowed_values
    (0 .. (Max/Increment)).map do |i|
      i *= Increment
      [i, i]
    end
  end

  belongs_to :user
  belongs_to :product
  validates :rating, :user_id, :product_id, :presence => true
  
  def to_f
    self.rating
  end

  class ValueValidator < ActiveModel::Validator
    def validate(record)
      unless allowed_values.member?(record.rating)
        record.errors[:rating] << 'Invalid rating value'
      end
    end
  end
end
