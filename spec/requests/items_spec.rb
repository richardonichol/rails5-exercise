require 'rails_helper'

RSpec.describe 'items' do

  let!(:todo) { FactoryGirl.create(:todo) }
  let!(:item) { FactoryGirl.create(:item, todo: todo) }
  let!(:completed_todo) { FactoryGirl.create(:todo, completed: true) }
  let!(:completed_item) { FactoryGirl.create(:item, completed: true, todo: completed_todo) }
  let!(:mixed_todo) { FactoryGirl.create(:todo)}
  let!(:mixed_item1) { FactoryGirl.create(:item, completed: true, todo: mixed_todo) }
  let!(:mixed_item2) { FactoryGirl.create(:item, todo: mixed_todo) }

  describe 'GET /todos/n/items' do

    it 'returns all the items' do
      get "/todos/#{todo.to_param}/items"
      expect(parsed_body.length).to eq 1
      expect(parsed_body.first['id']).to eq item.id
      expect(response).to be_success
    end

  end

  describe 'GET /todos/n/items/n' do

    it 'returns a single item' do
      get "/todos/#{todo.to_param}/items/#{item.to_param}"
      expect(parsed_body['id']).to eq item.id
      expect(response).to be_success
    end

  end

  describe 'POST /todos/n/items' do
    it 'creates an item' do
      expect {
        post "/todos/#{todo.to_param}/items", params: {title: 'New todo'}
        expect(parsed_body['title']).to eq 'New todo'
      }.to change(todo.items, :count).by(1)
    end

    it 'sets todo to incomplete if item is incomplete' do
      post "/todos/#{completed_todo.to_param}/items", params: {title: 'New incomplete item'}
      expect(completed_todo.reload.completed).to eq false
    end

    it 'sets todo to complete if all items are complete' do
      post "/todos/#{completed_todo.to_param}/items", params: {title: 'New completed item', completed: true}
      expect(completed_todo.reload.completed).to eq true
    end

    it 'leaves todo incomplete if any item is incomplete' do
      post "/todos/#{todo.to_param}/items", params: {title: 'New completed item', completed: true}
      expect(todo.reload.completed).to eq false
    end
  end

  describe 'PATCH /todos/n/items/n' do
    it 'updates an item' do
      expect(item.title).to_not eq 'New title'
      patch(
        "/todos/#{todo.to_param}/items/#{item.to_param}",
        params: {title: 'New title'}
      )
      expect(parsed_body['title']).to eq 'New title'
      expect(response).to be_success
      expect(item.reload.title).to eq 'New title'
    end

    it 'sets todo to incomplete when item is set to incomplete' do
      patch(
        "/todos/#{completed_todo.to_param}/items/#{completed_item.to_param}",
        params: {completed: false}
      )
      expect(response).to be_success
      expect(completed_todo.reload.completed).to eq false
    end

    it 'sets todo to complete if all items are complete' do
      patch(
        "/todos/#{todo.to_param}/items/#{item.to_param}",
        params: {completed: true}
      )
      expect(response).to be_success
      expect(todo.reload.completed).to eq true
    end
  end

  describe 'DELETE /todos/n/items/n' do
    it 'deletes the item' do
      expect {
        delete "/todos/#{todo.to_param}/items/#{item.to_param}"
        expect(response.status).to eq 204
        expect(response.body).to be_empty
      }.to change(Item, :count).by(-1)
    end

    it 'sets todo to completed if all remaining items are completed' do
      delete "/todos/#{mixed_todo.to_param}/items/#{mixed_item2.to_param}"
      expect(mixed_todo.reload.completed).to eq true
    end

    it 'sets todo to incomplete if no items remain' do
      delete "/todos/#{completed_todo.to_param}/items/#{completed_item.to_param}"
      expect(completed_todo.reload.items.count).to eq 0
      expect(completed_todo.reload.completed).to eq false
    end
  end

  private
  def parsed_body
    @parsed_body ||= JSON.parse(response.body)
  end

end
