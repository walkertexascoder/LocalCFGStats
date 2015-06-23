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

ActiveRecord::Schema.define(version: 20150623083621) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitions", force: :cascade do |t|
    t.jsonb    "tags"
    t.jsonb    "events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "competitions", ["events"], name: "index_competitions_on_events", using: :gin
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
    t.jsonb    "results"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "competition_id"
  end

  add_index "entries", ["competition_id"], name: "index_entries_on_competition_id", using: :btree
  add_index "entries", ["competitor_id"], name: "index_entries_on_competitor_id", using: :btree
  add_index "entries", ["results"], name: "index_entries_on_results", using: :gin
  add_index "entries", ["tags"], name: "index_entries_on_tags", using: :gin

end
