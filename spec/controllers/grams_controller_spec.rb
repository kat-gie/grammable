require 'rails_helper'

RSpec.describe GramsController, type: :controller do
#destroy
  describe "grams#destroy action" do 
    it "shouldn't allow users who didn't create the gram to destroy it" do 
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end 

    it "shouldn't let unauthenticated users destroy a gram" do 
      gram = FactoryGirl.create(:gram)
      delete :destroy, id: gram.id 
      expect(response).to redirect_to new_user_session_path
    end 

    it "should allow a user to destroy grams" do 
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      delete :destroy, id: gram.id 
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end 

    it "should return a 404 if we can't find a gram with the specified ID" do 
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: 'SPACEDUCK'
      expect(response).to have_http_status(:not_found)
    end 
  end 

#update
  describe "grams#update action" do
    it "shouldn't let users who didn't create the gram update it" do 
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user 
      patch :update, id: gram.id, gram: { message: 'yasss' }
      expect(response).to have_http_status(:forbidden)
    end 

    it "shouldn't let unauthenticated users update a gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, id: gram.id, gram: { message: "Hello" }
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do 
      gram = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in gram.user 
      patch :update, id: gram.id, gram: { message: 'Changed' }
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "Changed"
    end 

    it "should return a 404 if the gram can't be found" do
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, id: 'KWEEN', gram: { message: 'Changed' }
      expect(response).to have_http_status(:not_found)
    end 

    it "should render the edit form with an http status of unprocessable_entity" do 
      gram = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in gram.user 
      patch :update, id: gram.id, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq "Initial Value"
    end 
  end 

#edit 
  describe "grams#edit action" do
    it "shouldn't let a user sho did not create the gram edit said gram" do 
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user 
      get :edit, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end 

    it "shouldn't let unauthenticated users edit a gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      get :edit, id: gram.id 
      expect(response).to have_http_status(:success)
    end 

    it "should return a 404 if the gram is not found" do 
      user = FactoryGirl.create(:user)
      sign_in user 
      get :edit, id: 'LOSERLY'
      expect(response).to have_http_status(:not_found)
    end 
  end 

#show
  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do 
      gram = FactoryGirl.create(:gram)
      get :show, id: gram.id 
      expect(response).to have_http_status(:success)
    end 

    it "should return a 404 if the gram is not found" do
      get :show, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end 
  end 

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end 
  end 

  describe "grams#new action" do 
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end 

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user 

      get :new
      expect(response).to have_http_status(:success)
    end 
  end 

#create
  describe "grams#create action" do 
    it "should require users to be logged in" do
      post :create, gram: { message: "Hello" }
      expect(response).to redirect_to new_user_session_path
    end 

    it "should successfully create a new gram in our db" do
      user = FactoryGirl.create(:user)
      sign_in user 

      post :create, params: {
        gram: {
          message: 'Hello!',
          picture: fixture_file_upload("/picture.png", 'image/png')
        }
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end 

    it "should properly deal with validation errors" do 
      user = FactoryGirl.create(:user)
      sign_in user 

      gram_count = Gram.count 
      post :create, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end 
  end 
end

