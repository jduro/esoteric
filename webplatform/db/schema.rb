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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130529152341) do

  create_table "educationalcontexts", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servicehascontexts", :id => false, :force => true do |t|
    t.integer "service_id"
    t.integer "educationalcontext_id"
  end

  add_index "servicehascontexts", ["service_id", "educationalcontext_id"], :name => "index_servicehascontexts"

  create_table "services", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "urlCourse"
    t.string   "path"
    t.string   "organization"
    t.boolean  "isCourse",     :default => false
    t.boolean  "haveInfo",     :default => true
    t.integer  "cogn",         :default => 0
    t.integer  "know",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unithascontexts", :id => false, :force => true do |t|
    t.integer "unit_id"
    t.integer "educationalcontext_id"
  end

  add_index "unithascontexts", ["unit_id", "educationalcontext_id"], :name => "index_unithascontexts"

  create_table "units", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "haveInfo",   :default => true
    t.integer  "cogn",       :default => 0
    t.integer  "know",       :default => 0
  end

end
