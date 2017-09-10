class ItemsController < ApplicationController
  def index
    @todo = Todo.find(params[:todo_id])
    @items = @todo.items.all
    render(json: @items)
  end

  def show
    @todo = Todo.find(params[:todo_id])
    @item = @todo.items.find(params[:id])
    render(json: @item)
  end

  def create
    ActiveRecord::Base.transaction do
      # Locking the todo first will prevent possible deadlocks
      @todo = Todo.lock.find(params[:todo_id])
      @item = @todo.items.create!(item_params)
      @todo.update!(completed: @item.completed && !@todo.items.incomplete.exists?)
    end
    render(json: @item)
  end

  def update
    ActiveRecord::Base.transaction do
      @todo = Todo.lock.find(params[:todo_id])
      @item = @todo.items.find(params[:id])
      @item.update!(item_params)
      @todo.update!(completed: @item.completed && !@todo.items.incomplete.exists?)
    end
    render(json: @item)
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy!
    @item.todo.update!(completed: @item.todo.items.exists? && !@item.todo.items.incomplete.exists?)
  end

  private

  def item_params
    params.permit(:title, :completed)
  end
end
