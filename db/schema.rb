# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160207131437) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "logs", force: :cascade do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "shared"
  end

  create_table "logs_tags", id: false, force: :cascade do |t|
    t.integer "log_id", null: false
    t.integer "tag_id", null: false
  end

  add_index "logs_tags", ["log_id", "tag_id"], name: "index_logs_tags_on_log_id_and_tag_id", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "tags_users", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "user_id"
  end

  create_table "trackpoints", force: :cascade do |t|
    t.integer  "track_id"
    t.float    "latitude",  null: false
    t.float    "longitude", null: false
    t.float    "elevation"
    t.datetime "time",      null: false
    t.float    "speed"
  end

  add_index "trackpoints", ["track_id"], name: "index_trackpoints_on_track_id", using: :btree

  create_table "tracks", force: :cascade do |t|
    t.integer  "log_id"
    t.float    "distance"
    t.float    "duration"
    t.float    "overall_average_speed"
    t.float    "max_speed"
    t.float    "ascent"
    t.float    "descent"
    t.float    "min_elevation"
    t.float    "max_elevation"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "moving_time"
    t.float    "stopped_time"
    t.float    "moving_average_speed"
    t.string   "name"
  end

  add_index "tracks", ["log_id"], name: "index_tracks_on_log_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "name"
    t.string   "password_digest"
    t.boolean  "is_admin",        default: false
    t.datetime "last_login_at"
    t.string   "distance_units"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_restricted"
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
