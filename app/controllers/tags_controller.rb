# encoding: utf-8

class TagsController < ApplicationController
  before_filter :authenticate

  def show
    @tag = Tag.find_by_name(params[:tag])
    @logs = current_user.visible_logs
      .select("logs.*, tracks.start_time")
      .includes(:tracks)
      .joins(:tags)
      .where("tags.name = ?", @tag.name)
      .order("tracks.start_time ASC")
      .all
      .uniq

    respond_to do |format|
      format.html

      format.json do
        data = @logs.map { |log|
          log.tracks.map { |track|
            {
            :name => log.name,
            :points => track.trackpoints.map { |trackpoint|
              {
                :latitude  => trackpoint.latitude,
                :longitude => trackpoint.longitude,
                :elevation => trackpoint.elevation,
                :speed     => trackpoint.speed,
                :timestamp => trackpoint.time.to_i,
                :time      => trackpoint.time.strftime("%d.%m.%Y %H:%M")
                }
              }
            }
          }
        }
        render :json => data.flatten
      end

      format.gpx do
        filename = "logs-tagged-#{@tag.name.parameterize}.gpx"
        headers["Content-Disposition"] = %{Content-Disposition: attachment; filename="#{filename}"}
      end
    end
  end

end
