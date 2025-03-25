class CreateRspecWatchdogsMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :rspec_watchdogs_metrics do |t|
      t.string :description
      t.string :file_path
      t.string :location
      t.float :run_time
      t.timestamps
    end
  end
end
