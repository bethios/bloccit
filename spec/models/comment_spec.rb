require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:topic) { create(:topic) }
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:comment) { create(:comment) }

  it { is_expected.to belong_to(:post) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_length_of(:body).is_at_least(5) }

  describe "attributes" do
    it "has a body attribute" do
      expect(comment).to have_attributes(body: comment.body)
    end
  end

#this is where the problem tests are.  Because earlier it had me set it so when you write a post it gets automatically
#favorited its messing this whole thing up and I don't know how to fix it.  The actual emailing gets done properly so I'm
#assuming the problem is the test.  this was my latest effort.
  describe "after_create" do
    before do
      @another_comment = Comment.new(body: 'Comment Body', post: post, user: user)
    end

    it "sends an email to users who have favorited the post" do
      favorite = user.favorites.create(post: post)
      expect(FavoriteMailer).to receive(:new_comment).with(user, post, @another_comment).and_return(double(deliver_now: true))

      @another_comment.save!
    end

    it "does not send emails to users who haven't favorited the post" do
      expect(FavoriteMailer).not_to receive(:new_comment)

      @another_comment.save!
    end
  end
end
