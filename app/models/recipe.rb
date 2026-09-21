class Recipe < ApplicationRecord
  IMAGE_CONTENT_TYPES = %w[ image/jpeg image/png image/webp ].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  has_many :ingredients, -> { order(:position, :id) },
           inverse_of: :recipe, dependent: :destroy

  # Set by the recipe form to discard the current photo without uploading a new one.
  attr_accessor :remove_image

  has_one_attached :image do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 200, 200 ]
    attachable.variant :display, resize_to_limit: [ 1200, 1200 ]
  end

  accepts_nested_attributes_for :ingredients,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs[:name].blank? }

  validates :title, presence: true, length: { maximum: 200 }
  validates :servings, :prep_time_minutes, :cook_time_minutes,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true

  validate :image_is_a_supported_type
  validate :image_is_within_the_size_limit

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

  # An attachment that failed validation is still in memory while the form is
  # redisplayed, and Active Storage cannot build a variant of, say, a text file.
  def displayable_image?
    image.attached? && image.variable?
  end

  def instruction_steps
    instructions.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end

  private

  def image_is_a_supported_type
    return unless image.attached?
    return if image.content_type.in?(IMAGE_CONTENT_TYPES)

    errors.add(:image, "must be a JPEG, PNG or WebP")
  end

  def image_is_within_the_size_limit
    return unless image.attached?
    return if image.byte_size <= MAX_IMAGE_SIZE

    errors.add(:image, "must be smaller than #{MAX_IMAGE_SIZE / 1.megabyte}MB")
  end
end
