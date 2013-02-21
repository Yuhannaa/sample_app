require 'spec_helper'

describe "MicropostPages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do
      
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') } 
      end
    end

    describe "with valid information" do
      
      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    # Exercises 10.5.4
    # Write a test to make sure delete links do not appear for microposts not created by the current user.
    describe "as incorrect user" do
      let(:another_user) { FactoryGirl.create(:user) }
      let!(:another_users_micropost) { FactoryGirl.create(:micropost, user: another_user) }

      before { visit user_path(another_user) }
      # before { visit root_path }

      it { should_not have_link('delete', href: micropost_path(another_users_micropost)) }
    end
  end

  # Exercises 10.5.2
  # Add tests for micropost pagination.
  describe "micropost pagination" do
    before do
      100.times { FactoryGirl.create(:micropost, user: user) }
      visit root_path
    end
    after { Micropost.delete_all }

    it { should have_selector('div.pagination') }

    it "should list each micropost" do
      Micropost.paginate(page: 1).each do |micropost|
        page.should have_selector('li', text: micropost.content)
      end
    end
  end
end
