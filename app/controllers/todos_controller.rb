class TodosController < ApplicationController
  def index
    @todos = Todo.all
    render(json: @todos)
  end

  def show
    @todo = Todo.find(params[:id])
    render(json: @todo)
  end

  def create
    @todo = Todo.create(todo_params)
    render(json: @todo)
  end

  def update
    @todo = Todo.find(params[:id])
    @todo.update(todo_params)
    render(json: @todo)
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
  end

  private
  
  def todo_params
    params.permit(:title)
  end
end
