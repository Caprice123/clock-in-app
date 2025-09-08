class AddIndexToSleepRecordsForUserCreatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index :sleep_records, %i[user_id created_at], order: { created_at: :desc }
  end
end
