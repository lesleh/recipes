class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true, length: { maximum: 200 }

  before_validation :assign_position, on: :create

  def to_s
    [ quantity, unit, name ].compact_blank.join(" ")
  end

  private

  def assign_position
    return if position.present? && position.positive?

    self.position = (recipe&.ingredients&.filter_map(&:position)&.max || 0) + 1
  end
end
