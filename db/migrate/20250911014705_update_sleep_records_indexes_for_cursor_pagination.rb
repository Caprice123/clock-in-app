class UpdateSleepRecordsIndexesForCursorPagination < ActiveRecord::Migration[7.1]
  def change
    remove_index :sleep_records, %i[user_id created_at]
    remove_index :sleep_records, %i[user_id aasm_state duration]

    add_index :sleep_records, %i[user_id created_at id],
      order: { created_at: :desc, id: :desc },
      name: "index_sleep_records_on_user_created_at_id"

    add_index :sleep_records, %i[user_id aasm_state duration id],
      order: { duration: :desc, id: :desc },
      name: "index_sleep_records_on_user_state_duration_id"
  end
end
