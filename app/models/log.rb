class Log < ApplicationRecord
  belongs_to :user

  has_many :tracks, -> { order(:start_time) }, dependent: :destroy
  has_many :trackpoints, through: :tracks
  has_and_belongs_to_many :tags, -> { order(:name) }

  attr_writer :tags_list
  attr_accessor :track_file

  validates :name, presence: true

  scope :for_user, ->(user) { where(:user_id => user.id) }

  def start_time
    @start_time ||= self.tracks.map(&:start_time).min
  end

  def end_time
    @end_time ||= self.tracks.map(&:end_time).max
  end

  def moving_time
    @moving_time ||= self.tracks.map(&:moving_time).sum
  end

  def stopped_time
    @stopped_time ||= self.tracks.map(&:stopped_time).sum
  end

  def duration
    @duration ||= self.tracks.map(&:duration).sum
  end

  def distance
    @distance ||= self.tracks.map(&:distance).sum
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
    @max_speed ||= self.tracks.map(&:max_speed).max
  end

  def ascent
    @ascent ||= self.tracks.map(&:ascent).sum
  end

  def descent
    @descent ||= self.tracks.map(&:descent).sum
  end

  def min_elevation
    @min_elevation ||= self.tracks.map(&:min_elevation).min
  end

  def max_elevation
    @max_elevation ||= self.tracks.map(&:max_elevation).max
  end

  def create_tracks_from_gpx(gpx)
    doc = Nokogiri::XML.parse(gpx)
    new_tracks = []
    ns = "http://www.topografix.com/GPX/1/0"
    nodes = doc.xpath("/g:gpx", "g" => ns)
    version = (nodes.size == 1) ? nodes.first["version"] : nil

    if version == "1.0"
      new_tracks = parse_gpx_1_0(doc)
    elsif version == "1.1"
      new_tracks = parse_gpx_1_1(doc)
    elsif version == nil
      new_tracks = parse_gpx_nil(doc)
    end

    new_tracks.each { |track| track.save! }
    new_tracks
  end

  def parse_gpx_1_0(doc)
    new_tracks = []
    ns = "http://www.topografix.com/GPX/1/0"

    doc.xpath("/g:gpx/g:rte", "g" => ns).each do |rte|
      tracks = []

      nodes = rte.xpath("./g:name", "g" => ns)
      track_name = (nodes.size == 1) ? nodes.first.text : nil

      track = self.tracks.new
      track.save!

      rtept_nodes = rte.xpath("./g:rtept", "g" => ns)
      rtept_nodes.each do |rtept|
        # Elevation
        nodes = rtept.xpath("./g:ele", "g" => ns)
        elevation = (nodes.size == 1) ? nodes.first.text.to_f : nil

        # Time
        nodes = rtept.xpath("./g:time", "g" => ns)
        time = (nodes.size == 1) ? Time.parse(nodes.first.text) : nil

        # Speed
        nodes = rtept.xpath("./g:speed", "g" => ns)
        speed = (nodes.size == 1) ? nodes.first.text.to_f.kilometer_per_hour : nil

        if time && rtept["lat"] && rtept["lon"]
          track.trackpoints.new(latitude:   rtept["lat"],
                                longitude:  rtept["lon"],
                                elevation:  elevation,
                                time:       time,
                                speed:      speed)
        end

      end

      if track.trackpoints.size > 2
        track.update_cached_information
        tracks << track
      end

      if track_name
        if tracks.size == 1
          tracks.first.name = track_name
        else
          tracks.each_with_index do |track, i|
            track.name = "#{track_name} ##{i + 1}"
          end
        end
      end

      new_tracks += tracks
    end
    new_tracks
  end

  def parse_gpx_1_1(doc)
    new_tracks = []
    ns = "http://www.topografix.com/GPX/1/1"

    doc.xpath("/g:gpx/g:trk", "g" => ns).each do |trk|
      tracks = []

      # Track name
      nodes = trk.xpath("./g:name", "g" => ns)
      track_name = (nodes.size == 1) ? nodes.first.text : nil

      # Track Segments
      trkseg_nodes = trk.xpath("./g:trkseg", "g" => ns)
      trkseg_nodes.each_with_index do |trkseg, i|
        track = self.tracks.new

        trkseg.xpath("./g:trkpt", "g" => ns).each do |trkpt|
          # Elevation
          nodes = trkpt.xpath("./g:ele", "g" => ns)
          elevation = (nodes.size == 1) ? nodes.first.text.to_f : nil

          # Time
          nodes = trkpt.xpath("./g:time", "g" => ns)
          time = (nodes.size == 1) ? Time.parse(nodes.first.text) : nil

          if time and trkpt["lat"] and trkpt["lon"]
            track.trackpoints.new \
              :latitude  => trkpt["lat"],
              :longitude => trkpt["lon"],
              :elevation => elevation,
              :time      => time
          end
        end

        if track.trackpoints.size > 2
          track.update_cached_information
          tracks << track
        end
      end

      if track_name
        if tracks.size == 1
          tracks.first.name = track_name
        else
          tracks.each_with_index do |track, i|
            track.name = "#{track_name} ##{i + 1}"
          end
        end
      end

      new_tracks += tracks
    end
    new_tracks
  end

  # tracks.select{ |t| t.start_time == nil }.each{ |t| t.destroy }
  def parse_gpx_nil(doc)
    new_tracks = []
    ns = "http://www.topografix.com/GPX/1/1"

    doc.xpath("/g:gpx/g:trk", "g" => ns).each do |trk|
      tracks = []

      # Track name
      nodes = trk.xpath("./g:name", "g" => ns)
      track_name = (nodes.size == 1) ? nodes.first.text : nil

      # Track Segments
      trkseg_nodes = trk.xpath("./g:trkseg", "g" => ns)
      trkseg_nodes.each_with_index do |trkseg, i|
        track = self.tracks.new
        track.save!

        trkseg.xpath("./g:trkpt", "g" => ns).each do |trkpt|
          # Elevation
          nodes = trkpt.xpath("./g:ele", "g" => ns)
          elevation = (nodes.size == 1) ? nodes.first.text.to_f : nil

          # Time
          nodes = trkpt.xpath("./g:time", "g" => ns)
          time = (nodes.size == 1) ? Time.parse(nodes.first.text) + 8.hours : nil
          if time < 15.years.ago
            time += 19.years + 7.months + 16.days
          end

          if time and trkpt["lat"] and trkpt["lon"]
            track.trackpoints.new \
              :latitude  => trkpt["lat"],
              :longitude => trkpt["lon"],
              :elevation => elevation,
              :time      => time
          end
        end

        if track.trackpoints.size > 2
          track.update_cached_information
          tracks << track
        end
        track.name = track_name
      end

      new_tracks += tracks
    end
    new_tracks
  end

  def rank
    @rank ||= begin
      if alternatives.count > 1
        logs = alternatives.map { |log| [log.id, log.duration] }
        logs.sort! { |a, b| a[1] <=> b[1] }

        if index = logs.map { |log| log.first }.index(self.id)
          return index + 1
        end
      end

      nil
    end
  end

  def alternatives
    @alternatives ||= self.user.logs.where(:name => self.name)
  end

  def tags_list
    self.tags.map(&:name).join(" ")
  end

  def tags_list=(tags)
    self.tags = tags
      .split(/\s+/)
      .map { |tag| Tag.normalize_name(tag) }
      .map { |tag| Tag.find_by_name(tag) || Tag.new(name: tag) }
  end
end
