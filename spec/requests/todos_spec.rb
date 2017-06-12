require 'rails_helper'

RSpec.describe 'todos' do

  let!(:todo) { FactoryGirl.create(:todo) }

  describe 'GET /todos' do

    it 'returns all the todos' do
      get '/todos'
      expect(parsed_body.length).to eq 1
      expect(parsed_body.first['id']).to eq todo.id
      expect(response).to be_success
    end

  end

  describe 'GET /todos/n' do

    it 'returns a single todo' do
      get "/todos/#{todo.to_param}"
      expect(parsed_body['id']).to eq todo.id
      expect(response).to be_success
    end

  end

  describe 'POST /todos' do
    it 'creates a todo' do
      expect {
        post '/todos', params: {:title => 'New todo'}
        expect(parsed_body['title']).to eq 'New todo'
      }.to change(Todo, :count).by(1)
    end
  end

  describe 'PATCH /todos/n' do
    it 'updates a todo' do
      expect(todo.title).to_not eq 'New title'
      patch "/todos/#{todo.to_param}", params: {title: 'New title'}
      expect(parsed_body['title']).to eq 'New title'
      expect(response).to be_success
      expect(todo.reload.title).to eq 'New title'
    end
  end

  describe 'DELETE /todos/n' do
    it 'deletes the todo' do
      expect {
        delete "/todos/#{todo.to_param}"
        expect(response.status).to eq 204
        expect(response.body).to be_empty
      }.to change(Todo, :count).by(-1)
    end
  end

  private
  def parsed_body
    @parsed_body ||= JSON.parse(response.body)
  end

end
