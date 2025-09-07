class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.bigint :user_id, null: false
      t.bigint :followed_user_id, null: false

      t.timestamps
    end

    add_index :follows, %i[user_id followed_user_id], unique: true
    add_index :follows, :followed_user_id
  end
end
