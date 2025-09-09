class CreateUserStatistics < ActiveRecord::Migration[7.1]
  def change
    create_table :user_statistics do |t|
      t.bigint :user_id, null: false

      t.integer :total_sleep_records, default: 0
      t.integer :total_awake_records, default: 0
      t.bigint :total_sleep_duration, default: 0
      t.decimal :average_sleep_duration, precision: 8, scale: 2, default: 0.0
      t.datetime :last_calculated_at

      t.timestamps
    end

    add_index :user_statistics, :user_id, unique: true
    add_index :user_statistics, :last_calculated_at
  end
end
