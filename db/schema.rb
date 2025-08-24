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

ActiveRecord::Schema.define(version: 20200215071213) do

  create_table "administrators", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "hashed_password", limit: 255
    t.string   "salt",            limit: 255
    t.string   "role",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "content",     limit: 255
    t.datetime "deleted_at"
  end

  add_index "answers", ["deleted_at"], name: "index_answers_on_deleted_at", using: :btree

  create_table "app_logs", force: :cascade do |t|
    t.string   "log_type",   limit: 255
    t.text     "content",    limit: 65535
    t.datetime "created_at"
    t.text     "device",     limit: 65535
  end

  create_table "articles", force: :cascade do |t|
    t.string "title",   limit: 255
    t.text   "content", limit: 65535
  end

  create_table "authentication_tokens", id: false, force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "token",      limit: 8
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "user_type",  limit: 255
    t.string   "ip_address", limit: 255
    t.boolean  "is_active",              default: true
  end

  add_index "authentication_tokens", ["token"], name: "index_authentication_tokens_on_token", using: :btree

  create_table "badge_types", force: :cascade do |t|
    t.string  "badge_type",               limit: 255
    t.string  "name",                     limit: 255
    t.integer "number_of_efforts_to_get", limit: 4
    t.string  "image",                    limit: 255
  end

  create_table "badges", force: :cascade do |t|
    t.integer "user_id",          limit: 4
    t.integer "badge_type_id",    limit: 4
    t.integer "number_of_badges", limit: 4
  end

  create_table "common_word_meaning_groups", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "common_word_meanings", force: :cascade do |t|
    t.integer "common_word_id",               limit: 4
    t.string  "content",                      limit: 255
    t.string  "word_type",                    limit: 255
    t.text    "meaning",                      limit: 65535
    t.boolean "selected",                                   default: false
    t.string  "type_name",                    limit: 255
    t.integer "popularity",                   limit: 4,     default: 1
    t.integer "common_word_meaning_group_id", limit: 4
  end

  create_table "common_words", force: :cascade do |t|
    t.string  "content",               limit: 255
    t.string  "word_type",             limit: 255
    t.string  "meaning",               limit: 255
    t.text    "context",               limit: 65535
    t.integer "meaning_finding_times", limit: 4,     default: 0
    t.boolean "meaning_fetched",                     default: false
  end

  create_table "compliments", force: :cascade do |t|
    t.string  "from",                  limit: 255
    t.string  "for_task",              limit: 255
    t.string  "for_gender",            limit: 255
    t.string  "content",               limit: 255
    t.integer "for_correctness_level", limit: 4
  end

  create_table "contractions", force: :cascade do |t|
    t.string "content", limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,        default: 0
    t.integer  "attempts",   limit: 4,        default: 0
    t.text     "handler",    limit: 16777215
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "device_keys", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "key",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "platform",   limit: 255
  end

  create_table "espinita_audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.text     "audited_changes", limit: 65535
    t.string   "comment",         limit: 255
    t.integer  "version",         limit: 4
    t.string   "action",          limit: 255
    t.string   "remote_address",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "espinita_audits", ["auditable_id", "auditable_type"], name: "index_espinita_audits_on_auditable_id_and_auditable_type", using: :btree
  add_index "espinita_audits", ["user_id", "user_type"], name: "index_espinita_audits_on_user_id_and_user_type", using: :btree

  create_table "example_alternatives", force: :cascade do |t|
    t.integer  "example_id", limit: 4
    t.string   "content",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "example_point_links", force: :cascade do |t|
    t.integer "example_id", limit: 4
    t.integer "point_id",   limit: 4
  end

  create_table "examples", force: :cascade do |t|
    t.integer  "point_id",           limit: 4
    t.string   "content",            limit: 255
    t.string   "meaning",            limit: 255
    t.integer  "sound_id",           limit: 4
    t.integer  "grammar_point_id",   limit: 4
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.boolean  "is_linked_to_words",             default: false
    t.boolean  "skip_finding_sound",             default: false
  end

  add_index "examples", ["deleted_at"], name: "index_examples_on_deleted_at", using: :btree

  create_table "friend_teasers", force: :cascade do |t|
    t.string  "teasing_phase",  limit: 255
    t.boolean "is_active"
    t.integer "selected_times", limit: 4,   default: 0
  end

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "friend_id",  limit: 4
    t.datetime "created_on"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "grammar_points", force: :cascade do |t|
    t.integer  "lesson_id",  limit: 4
    t.string   "content",    limit: 255
    t.datetime "deleted_at"
    t.datetime "updated_at"
  end

  add_index "grammar_points", ["deleted_at"], name: "index_grammar_points_on_deleted_at", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "sender_id",      limit: 4
    t.string   "receiver_email", limit: 255
    t.datetime "created_on"
  end

  add_index "invitations", ["sender_id"], name: "index_invitations_on_sender_id", using: :btree

  create_table "lessons", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "syllabus_id",      limit: 4
    t.string   "video_url",        limit: 255
    t.text     "content",          limit: 65535
    t.integer  "position",         limit: 4
    t.boolean  "active",                         default: false
    t.datetime "deleted_at"
    t.integer  "master_lesson_id", limit: 4
    t.integer  "article_id",       limit: 4
  end

  add_index "lessons", ["deleted_at"], name: "index_lessons_on_deleted_at", using: :btree

  create_table "levels", force: :cascade do |t|
    t.datetime "deleted_at"
    t.integer  "highest_score", limit: 4, default: 0
    t.integer  "position",      limit: 4, default: 0
  end

  add_index "levels", ["deleted_at"], name: "index_levels_on_deleted_at", using: :btree
  add_index "levels", ["highest_score"], name: "index_levels_on_highest_score", using: :btree

  create_table "metrics", id: false, force: :cascade do |t|
    t.integer  "group_id",   limit: 8
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "created_at", limit: 255
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "type",          limit: 255
    t.integer  "from_user_id",  limit: 4
    t.integer  "to_user_id",    limit: 4
    t.boolean  "is_processed",                default: false
    t.text     "data",          limit: 65535
    t.datetime "defer_until"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "from_event_id", limit: 4
  end

  create_table "opportunities", force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.integer "badge_type_id", limit: 4
    t.boolean "is_taken"
  end

  create_table "point_images", force: :cascade do |t|
    t.integer "point_id",      limit: 4
    t.string  "image",         limit: 255
    t.string  "cropping_data", limit: 255
  end

  create_table "points", force: :cascade do |t|
    t.integer  "list_id",                    limit: 4
    t.integer  "lesson_id",                  limit: 4
    t.string   "content",                    limit: 255
    t.string   "point_type",                 limit: 255
    t.string   "meaning_in_english",         limit: 255
    t.string   "meaning",                    limit: 255
    t.integer  "sound_id",                   limit: 4
    t.integer  "sound2_id",                  limit: 4
    t.boolean  "sound_verified",                           default: true
    t.integer  "main_example_id",            limit: 4
    t.boolean  "is_valid",                                 default: false
    t.datetime "deleted_at"
    t.integer  "position",                   limit: 4
    t.string   "split_content",              limit: 255
    t.string   "google_search_key",          limit: 255
    t.string   "pronunciation",              limit: 255
    t.text     "possible_pronunciations",    limit: 65535
    t.boolean  "is_private",                               default: false
    t.integer  "adding_user_id",             limit: 4
    t.boolean  "is_supporting",                            default: false
    t.datetime "updated_at"
    t.string   "is_illustrated",             limit: 255,   default: "no"
    t.boolean  "skip_finding_sound",                       default: false
    t.boolean  "skip_finding_pronunciation",               default: false
  end

  add_index "points", ["content"], name: "index_points_on_content", using: :btree
  add_index "points", ["deleted_at"], name: "index_points_on_deleted_at", using: :btree

  create_table "push_notifications", force: :cascade do |t|
    t.integer  "to_user_id",     limit: 4
    t.string   "message",        limit: 255
    t.boolean  "sent",                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "to_device_keys", limit: 65535
    t.string   "platform",       limit: 255
  end

  create_table "questions", force: :cascade do |t|
    t.integer  "point_id",                       limit: 4
    t.string   "content",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid",                                   default: false
    t.integer  "right_answer_id",                limit: 4
    t.datetime "deleted_at"
    t.integer  "right_answer_explanation_id",    limit: 4
    t.string   "right_answer_explanation_parts", limit: 255
    t.integer  "grammar_point_id",               limit: 4
    t.string   "question_type",                  limit: 255, default: "choosing"
    t.string   "answer",                         limit: 255, default: ""
  end

  add_index "questions", ["deleted_at"], name: "index_questions_on_deleted_at", using: :btree

  create_table "review_skills", force: :cascade do |t|
    t.integer "review_id",                  limit: 4
    t.integer "skill",                      limit: 1
    t.integer "reviewed_times",             limit: 2, default: 0
    t.integer "effectively_reviewed_times", limit: 2, default: 0
    t.integer "reminded_times",             limit: 2, default: 0
    t.date    "review_due_date"
    t.date    "last_reviewed_date"
  end

  create_table "review_summaries", force: :cascade do |t|
    t.integer "user_id",                        limit: 4
    t.date    "date"
    t.integer "continuous_reviewing_days",      limit: 4
    t.integer "number_of_reviewed_items_today", limit: 4
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id",   limit: 4
    t.integer "point_id",  limit: 4
    t.boolean "is_active",           default: true
  end

  add_index "reviews", ["user_id", "point_id", "is_active"], name: "index_reviews_on_user_id_and_point_id_and_is_active", using: :btree

  create_table "right_answer_explanations", force: :cascade do |t|
    t.integer "lesson_id",   limit: 4
    t.string  "explanation", limit: 255
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                    limit: 255,               null: false
    t.string   "environment",             limit: 255
    t.text     "certificate",             limit: 65535
    t.string   "password",                limit: 255
    t.integer  "connections",             limit: 4,     default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                    limit: 255,               null: false
    t.string   "auth_key",                limit: 255
    t.string   "client_id",               limit: 255
    t.string   "client_secret",           limit: 255
    t.string   "access_token",            limit: 255
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id",       limit: 4
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge",             limit: 4
    t.string   "device_token",      limit: 64
    t.string   "sound",             limit: 255,      default: "default"
    t.text     "alert",             limit: 65535
    t.text     "data",              limit: 65535
    t.integer  "expiry",            limit: 4,        default: 86400
    t.boolean  "delivered",                          default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                             default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code",        limit: 4
    t.text     "error_description", limit: 65535
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                      default: false
    t.string   "type",              limit: 255,                          null: false
    t.string   "collapse_key",      limit: 255
    t.boolean  "delay_while_idle",                   default: false,     null: false
    t.text     "registration_ids",  limit: 16777215
    t.integer  "app_id",            limit: 4,                            null: false
    t.integer  "retries",           limit: 4,        default: 0
    t.string   "uri",               limit: 255
    t.datetime "fail_after"
    t.boolean  "processing",                         default: false,     null: false
    t.integer  "priority",          limit: 4
    t.text     "url_args",          limit: 65535
    t.string   "category",          limit: 255
    t.boolean  "content_available",                  default: false
    t.text     "notification",      limit: 65535
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi", using: :btree
  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "slow_queries", force: :cascade do |t|
    t.float    "duration",   limit: 24
    t.text     "query",      limit: 65535
    t.datetime "created_at"
  end

  create_table "slow_requests", force: :cascade do |t|
    t.string   "controller",   limit: 255
    t.string   "action",       limit: 255
    t.float    "duration",     limit: 24
    t.float    "db_runtime",   limit: 24
    t.float    "view_runtime", limit: 24
    t.text     "params",       limit: 65535
    t.datetime "created_at"
  end

  create_table "sounds", force: :cascade do |t|
    t.string   "for_content",   limit: 255
    t.binary   "ogg",           limit: 65535
    t.binary   "mp3",           limit: 65535
    t.boolean  "fetched",                     default: false
    t.integer  "fetched_times", limit: 4,     default: 0
    t.datetime "updated_at"
  end

  add_index "sounds", ["for_content"], name: "index_sounds_on_for_content", using: :btree

  create_table "syllabuses", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "syllabus_order", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taken_test_items", force: :cascade do |t|
    t.integer "taken_test_id",    limit: 4
    t.integer "question_id",      limit: 4
    t.integer "chosen_answer_id", limit: 4
  end

  create_table "taken_tests", force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.date    "created_on"
    t.boolean "is_passed"
    t.boolean "finished",             default: false
    t.integer "lesson_id",  limit: 4
  end

  create_table "user_actions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "type",       limit: 255
    t.text     "data",       limit: 65535
    t.datetime "created_at"
  end

  create_table "user_configs", force: :cascade do |t|
    t.integer "user_id",                  limit: 4
    t.boolean "remind_already_mastering",           default: false
  end

  create_table "user_events", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "type",           limit: 255
    t.text     "data",           limit: 65535
    t.datetime "created_at"
    t.integer  "from_action_id", limit: 4
  end

  create_table "user_points", force: :cascade do |t|
    t.integer "user_id",                    limit: 4, default: 0
    t.integer "point_id",                   limit: 4, default: 0
    t.integer "reviewed_times",             limit: 4, default: 0
    t.integer "effectively_reviewed_times", limit: 4, default: 0
    t.date    "review_due_date"
    t.date    "last_reviewed_date"
    t.integer "reminded_times",             limit: 4, default: 0
  end

  create_table "user_ui_actions", force: :cascade do |t|
    t.integer "user_id",     limit: 4
    t.string  "action",      limit: 255
    t.text    "action_data", limit: 65535
    t.integer "action_time", limit: 8
    t.string  "view",        limit: 255
    t.text    "device",      limit: 65535
    t.string  "ip_address",  limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                 limit: 255
    t.string   "middle_name",                limit: 255
    t.string   "last_name",                  limit: 255
    t.string   "email",                      limit: 255
    t.string   "hashed_password",            limit: 255
    t.string   "salt",                       limit: 255
    t.date     "birthday"
    t.string   "gender",                     limit: 255
    t.integer  "status",                     limit: 4,   default: 0
    t.string   "confirmation_hash",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_id",                   limit: 4
    t.integer  "current_lesson_id",          limit: 4
    t.date     "test_passed_date"
    t.string   "avatar",                     limit: 255
    t.string   "image_of_beloved",           limit: 255
    t.string   "relationship_to_beloved",    limit: 255
    t.boolean  "image_of_beloved_ready",                 default: false
    t.integer  "score",                      limit: 4,   default: 0
    t.string   "user_type",                  limit: 255, default: "normal"
    t.string   "hashed_recovering_password", limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree

  create_table "word_variations", force: :cascade do |t|
    t.integer "point_id", limit: 4
    t.string  "content",  limit: 255
  end

  add_index "word_variations", ["content"], name: "index_word_variations_on_content", using: :btree

end
