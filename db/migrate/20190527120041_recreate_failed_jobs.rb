class RecreateFailedJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :failed_jobs, id: :uuid, force: true do |t|
      t.uuid :original_id, null: false, unique: true
      t.jsonb :data, null: false
      t.text :log, null: false
      t.jsonb :artifacts, null: false
      t.datetime :original_created_at, null: false
      t.integer :build_number, null: false
      t.jsonb :build_data, null: false

      t.timestamps
    end
  end
end
