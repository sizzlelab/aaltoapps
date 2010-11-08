class Rating < ActiveRecord::Base
  Min = 0
  Max = 5
  Increment = 0.5

  def self.allowed_values
    values = []
    (Min..Max).step(Increment) do |val|
      values << val
    end
    values
  end

  class RatingValueValidator < ActiveModel::Validator
    def validate(record)
      if record.rating.nil?
        record.errors[:rating] << "can't be blank"
      elsif ! Rating::allowed_values.member?(record.rating)
        record.errors[:rating] << "has invalid value"
      end
    end
  end

  belongs_to :user
  belongs_to :product
  validates :user_id, :product_id, :presence => true
  validates_with RatingValueValidator

  def to_f
    self.rating
  end
end
