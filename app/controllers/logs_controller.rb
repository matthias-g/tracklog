# encoding: utf-8

class LogsController < ApplicationController
  before_action :authenticate
  before_action :find_log_and_check_read_permission, only: [:show, :tracks]
  before_action :find_log_and_check_write_permission, only: [:edit, :update, :destroy]
  before_action :redirect_restricted_users, only: [:new, :create]

  def index
    @selected_year = params[:year] ? params[:year].to_i : Time.now.year

    @available_years = current_user
      .visible_tracks
      .select("tracks.start_time")
      .order("tracks.start_time ASC")
      .map { |track| track.start_time.year }
      .uniq

    @logs = current_user
      .visible_logs
      .select("logs.*, tracks.start_time")
      .includes(:tracks)
      .where("tracks.start_time >= ?", Time.mktime(@selected_year, 1, 1))
      .where("tracks.start_time < ?", Time.mktime(@selected_year + 1, 1, 1))
      .order("tracks.start_time ASC")
      .all
      .uniq

    calculate_list
  end

  def tagged
    @logs = current_user.visible_logs
      .select("logs.*, tracks.start_time")
      .includes(:tracks)
      .joins(:tags)
      .where("tags.name = ?", params[:tag])
      .order("tracks.start_time ASC")
      .all
      .uniq

    calculate_list
  end

  def show
    respond_to do |format|
      format.html

      format.json do
        render :json => @log.tracks.map { |track|
          {
            :name => track.display_name,
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
      end

      format.gpx do
        filename = "log-#{@log.id}-#{@log.name.parameterize}.gpx"
        headers["Content-Disposition"] = %{Content-Disposition: attachment; filename="#{filename}"}
      end
    end
  end

  def tracks
    respond_to do |format|
      format.json do
        render :json => {
          :distance_units => current_user.distance_units,
          :tracks => @log.tracks.map { |track|
            track.trackpoints.map do |trackpoint|
              {
                :latitude  => trackpoint.latitude,
                :longitude => trackpoint.longitude,
                :elevation => trackpoint.elevation,
                :speed     => trackpoint.speed,
                :timestamp => trackpoint.time.to_i,
                :time      => trackpoint.time.strftime("%d.%m.%Y %H:%M")
              }
            end
          }
        }
      end
    end
  end

  def new
    @log = Log.new
  end

  def create
    @log = Log.new(log_params)
    @log.user = current_user

    unless @log.save
      render :action => :new and return
    end

    if track_file = log_params[:track_file]
      @log.create_tracks_from_gpx(track_file.read)
    end

    redirect_to @log
  end

  def edit
    @orig_log = @log.dup
  end

  def update
    @orig_log = @log.dup

    if @log.update_attributes(log_params)
      redirect_to @log
    else
      flash[:error] = "There was an error updating the log."
      render :edit
    end
  end

  def destroy
    @log.destroy
    redirect_to @log
  end

  private

  def find_log_and_check_read_permission
    @log = Log.find(params[:id])

    unless @log.in? current_user.visible_logs
      flash[:error] = "You don’t have permission to view this log."
      redirect_to dashboard_path and return
    end
  end

  def find_log_and_check_write_permission
    @log = Log.find(params[:id])

    unless @log.user_id == current_user.id
      flash[:error] = "You don’t have permission to edit this log."
      redirect_to dashboard_path and return
    end
  end

  def calculate_list
    @total_distance = 0.0
    @total_duration = 0.0
    @logs_by_months = {}

    @logs.each do |log|
      @total_distance += log.distance
      @total_duration += log.duration

      time = Time.mktime(log.start_time.year, log.start_time.month, 1)

      @logs_by_months[time] ||= {
        :logs => [],
        :total_distance => 0.0,
        :total_duration => 0.0
      }

      @logs_by_months[time][:logs] << log
      @logs_by_months[time][:total_distance] += log.distance
      @logs_by_months[time][:total_duration] += log.duration
    end
  end

  def log_params
    params.require(:log).permit(:name, :comment, :tags_list, :track_file, :shared)
  end

  def redirect_restricted_users
    redirect_to dashboard_path if current_user.is_restricted?
  end
end
