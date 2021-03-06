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

ActiveRecord::Schema.define(version: 20180209163146) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "businesses", force: :cascade do |t|
    t.string "name"
    t.string "org_id"
    t.string "desc1"
    t.string "desc2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cycles", force: :cascade do |t|
    t.string "year"
    t.integer "total"
    t.integer "dem_amount"
    t.integer "rep_amount"
    t.integer "dem_pct"
    t.integer "rep_pct"
    t.bigint "business_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_cycles_on_business_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date"
    t.string "description"
    t.string "original"
    t.float "amount"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "business_id"
    t.index ["business_id"], name: "index_transactions_on_business_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "newest_month"
    t.date "oldest_month"
    t.string "password_digest"
  end

  add_foreign_key "cycles", "businesses"
  add_foreign_key "transactions", "businesses"
  add_foreign_key "transactions", "users"
end
