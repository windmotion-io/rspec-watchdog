class CreateRspecWatchdogMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :rspec_watchdog_metrics do |t|
      t.string :description
      t.string :file_path
      t.string :location
      t.float :run_time
      t.string :status
      t.text :error_message # mensaje de error si la prueba falla
      t.timestamps
    end
  end
end

