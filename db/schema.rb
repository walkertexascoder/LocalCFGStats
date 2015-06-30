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

ActiveRecord::Schema.define(version: 20150630090401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitions", force: :cascade do |t|
    t.jsonb    "tags"
    t.jsonb    "event_attrs"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "competitions", ["event_attrs"], name: "index_competitions_on_event_attrs", using: :gin
  add_index "competitions", ["tags"], name: "index_competitions_on_tags", using: :gin

  create_table "competitors", force: :cascade do |t|
    t.integer  "hq_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "competitors", ["hq_id"], name: "index_competitors_on_hq_id", using: :btree

  create_table "entries", force: :cascade do |t|
    t.integer  "competitor_id"
    t.jsonb    "tags"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "competition_id"
  end

  add_index "entries", ["competition_id"], name: "index_entries_on_competition_id", using: :btree
  add_index "entries", ["competitor_id"], name: "index_entries_on_competitor_id", using: :btree
  add_index "entries", ["tags"], name: "index_entries_on_tags", using: :gin

  create_table "results", force: :cascade do |t|
    t.integer  "competition_id"
    t.integer  "entry_id"
    t.integer  "event_num"
    t.string   "raw"
    t.float    "normalized"
    t.boolean  "time_capped"
    t.integer  "rank"
    t.float    "mean"
    t.float    "std_dev"
    t.float    "est_mean"
    t.float    "est_std_dev"
    t.float    "standout"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.jsonb    "tags"
    t.integer  "competitor_id"
    t.string   "raw_std_dev"
    t.string   "raw_mean"
    t.string   "raw_est_mean"
    t.string   "raw_est_std_dev"
    t.float    "est_standout"
    t.string   "est_raw"
    t.float    "est_normalized"
  end

  add_index "results", ["competition_id"], name: "index_results_on_competition_id", using: :btree
  add_index "results", ["competitor_id"], name: "index_results_on_competitor_id", using: :btree
  add_index "results", ["entry_id"], name: "index_results_on_entry_id", using: :btree
  add_index "results", ["est_mean"], name: "index_results_on_est_mean", using: :btree
  add_index "results", ["est_standout"], name: "index_results_on_est_standout", using: :btree
  add_index "results", ["est_std_dev"], name: "index_results_on_est_std_dev", using: :btree
  add_index "results", ["event_num"], name: "index_results_on_event_num", using: :btree
  add_index "results", ["mean"], name: "index_results_on_mean", using: :btree
  add_index "results", ["normalized"], name: "index_results_on_normalized", using: :btree
  add_index "results", ["rank"], name: "index_results_on_rank", using: :btree
  add_index "results", ["raw"], name: "index_results_on_raw", using: :btree
  add_index "results", ["standout"], name: "index_results_on_standout", using: :btree
  add_index "results", ["std_dev"], name: "index_results_on_std_dev", using: :btree
  add_index "results", ["tags"], name: "index_results_on_tags", using: :gin
  add_index "results", ["time_capped"], name: "index_results_on_time_capped", using: :btree

end
