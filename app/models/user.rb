class User < ActiveRecord::Base
  has_secure_password

  has_many :logs, dependent: :destroy
  has_many :tracks, through: :logs
  has_and_belongs_to_many :visible_tags, class_name: 'Tag'

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create
  validates :distance_units, inclusion: { in: [:imperial, :metric] }, unless: ->(s) { s.blank? }

  def visible_logs
    Log.joins('left join logs_tags on logs_tags.log_id = logs.id')
        .joins('left join tags_users on tags_users.tag_id = logs_tags.tag_id')
        .joins('left join users on tags_users.user_id = users.id')
        .where("logs.user_id = ? or users.id = ? or shared = 'T'", id, id)
  end

  def visible_tracks
    Track.joins('left join logs on logs.id = tracks.log_id')
        .joins('left join logs_tags on logs_tags.log_id = logs.id')
        .joins('left join tags_users on tags_users.tag_id = logs_tags.tag_id')
        .joins('left join users on tags_users.user_id = users.id')
        .where("logs.user_id = ? or logs.shared = 'T' or users.id = ?", id, id)
  end

  def display_name
    self.name.blank? ? self.username : self.name
  end

  def distance_units
    attributes["distance_units"].try(:to_sym) || Tracklog::Config.distance_units
  end
end
