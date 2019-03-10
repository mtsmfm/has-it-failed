class CreateFailedJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :failed_jobs, id: :uuid do |t|
      t.integer :original_id, null: false, unique: true
      t.jsonb :data, null: false
      t.integer :build_number, null: false
      t.jsonb :build_data, null: false
      t.jsonb :parse_result, null: false

      t.timestamps
    end
  end
end
