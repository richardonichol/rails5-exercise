namespace :migration do
  task :update_todos_completed_flag => :environment do
    # Default all todos with at least one item to true:
    Todo.joins(:items).update_all(completed: true)
    # Now set all todos with at least one incomplete item to incomplete:
    Todo.joins(:items).where(items: {completed: false}).update_all(completed: false)
  end
end