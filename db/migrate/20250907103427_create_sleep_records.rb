class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_records do |t|
      t.bigint :user_id, null: false
      t.string :aasm_state, null: false, default: "sleeping"
      t.datetime :sleep_time, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :wake_time
      t.integer :duration

      t.timestamps
    end

    add_index :sleep_records, %i[user_id aasm_state duration]
  end
end
