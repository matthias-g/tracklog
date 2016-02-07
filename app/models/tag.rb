class Tag < ActiveRecord::Base
  has_and_belongs_to_many :logs
  has_and_belongs_to_many :viewers, class_name: 'User'

  validates :name, presence: true, uniqueness: true
  before_save :normalize

  def to_param
    self.name
  end

  def self.normalize_name(name)
    UnicodeUtils.downcase(UnicodeUtils.nfkd(name))
  end

  def normalize
    self.name = Tag.normalize_name(self.name)
  end

  def start_time
    @start_time ||= self.logs.map(&:start_time).min
  end

  def end_time
    @end_time ||= self.logs.map(&:end_time).max
  end

  def moving_time
    @moving_time ||= self.logs.map(&:moving_time).sum
  end

  def stopped_time
    @stopped_time ||= self.logs.map(&:stopped_time).sum
  end

  def duration
    @duration ||= self.logs.map(&:duration).sum
  end

  def distance
    @distance ||= self.logs.map(&:distance).sum
  end

  def overall_average_speed
    @overall_average_speed ||= begin
      if distance > 0 and duration > 0
        distance / duration
      end
    end
  end

  def moving_average_speed
    @moving_average_speed ||= begin
      if distance > 0 and moving_time > 0
        distance / moving_time
      end
    end
  end

  def max_speed
    @max_speed ||= self.logs.map(&:max_speed).max
  end

  def ascent
    @ascent ||= self.logs.map(&:ascent).sum
  end

  def descent
    @descent ||= self.logs.map(&:descent).sum
  end

  def min_elevation
    @min_elevation ||= self.logs.map(&:min_elevation).min
  end

  def max_elevation
    @max_elevation ||= self.logs.map(&:max_elevation).max
  end
end
