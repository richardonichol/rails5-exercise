require 'rails_helper'

RSpec.describe 'items' do

  let!(:todo) { FactoryGirl.create(:todo) }
  let!(:item) { FactoryGirl.create(:item, todo: todo) }

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
        post "/todos/#{todo.to_param}/items", params: {:title => 'New todo'}
        expect(parsed_body['title']).to eq 'New todo'
      }.to change(todo.items, :count).by(1)
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
  end

  describe 'DELETE /todos/n/items/n' do
    it 'deletes the item' do
      expect {
        delete "/todos/#{todo.to_param}/items/#{item.to_param}"
        expect(response.status).to eq 204
        expect(response.body).to be_empty
      }.to change(Item, :count).by(-1)
    end
  end

  private
  def parsed_body
    @parsed_body ||= JSON.parse(response.body)
  end

end
