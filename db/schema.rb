# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_19_111000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "grocery_items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.bigint "grocery_list_id", null: false
    t.string "name"
    t.decimal "quantity"
    t.bigint "recipe_id"
    t.string "source"
    t.string "status"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["grocery_list_id"], name: "index_grocery_items_on_grocery_list_id"
    t.index ["recipe_id"], name: "index_grocery_items_on_recipe_id"
  end

  create_table "grocery_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "source"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_grocery_lists_on_user_id"
  end

  create_table "pantry_items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.date "expires_at"
    t.string "name"
    t.decimal "quantity"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_pantry_items_on_user_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "cook_time"
    t.datetime "created_at", null: false
    t.string "cuisine"
    t.text "description"
    t.jsonb "ingredients"
    t.text "instructions"
    t.string "name"
    t.integer "prep_time"
    t.integer "servings"
    t.string "source"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "ai_api_endpoint"
    t.string "ai_api_key"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "grocery_items", "grocery_lists"
  add_foreign_key "grocery_items", "recipes"
  add_foreign_key "grocery_lists", "users"
  add_foreign_key "pantry_items", "users"
  add_foreign_key "recipes", "users"
end
