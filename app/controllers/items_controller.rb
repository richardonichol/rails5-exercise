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
    @todo = Todo.find(params[:todo_id])
    @item = @todo.items.create(item_params)
    render(json: @item)
  end

  def update
    @todo = Todo.find(params[:todo_id])
    @item = @todo.items.find(params[:id])
    @item.update(item_params)
    render(json: @item)
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
  end

  private
  def item_params
    params.permit(:title, :completed)
  end
end
