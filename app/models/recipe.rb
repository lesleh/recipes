class Recipe < ApplicationRecord
  has_many :ingredients, -> { order(:position, :id) },
           inverse_of: :recipe, dependent: :destroy

  accepts_nested_attributes_for :ingredients,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs[:name].blank? }

  validates :title, presence: true, length: { maximum: 200 }
  validates :servings, :prep_time_minutes, :cook_time_minutes,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true

  scope :by_title, -> { order(:title) }

  # SQLite LIKE is case-insensitive for ASCII, which is all we need here.
  scope :search, ->(term) {
    next all if term.blank?

    pattern = "%#{sanitize_sql_like(term.strip)}%"
    left_joins(:ingredients)
      .where("recipes.title LIKE :q OR recipes.description LIKE :q OR ingredients.name LIKE :q", q: pattern)
      .distinct
  }

  def total_time_minutes
    return nil if prep_time_minutes.nil? && cook_time_minutes.nil?

    prep_time_minutes.to_i + cook_time_minutes.to_i
  end

  def instruction_steps
    instructions.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end
end
