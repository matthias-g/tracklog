# encoding: utf-8

class TagsController < ApplicationController
  before_action :authenticate
  before_action :redirect_non_admins, only: [:add_viewer, :delete_viewer]

  def show
    @tag = Tag.find_by_name(params[:tag])
    @logs = current_user.visible_logs
      .select("logs.*, tracks.start_time")
      .includes(:tracks)
      .joins('inner join tags on tags.id = logs_tags.tag_id')
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

  def add_viewer
    tag = Tag.find_by_name(params[:tag])
    viewer = User.find_by_username(params[:viewer])
    tag.viewers << viewer

    redirect_to tag_url(tag)
  end

  def delete_viewer
    tag = Tag.find_by_name(params[:tag])
    viewer = User.find_by_username(params[:viewer])
    tag.viewers.destroy(viewer)

    redirect_to tag_url(tag)
  end

  private

  def redirect_non_admins
    redirect_to dashboard_path unless current_user.is_admin?
  end

end
