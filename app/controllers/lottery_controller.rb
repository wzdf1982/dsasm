class LotteryController < ApplicationController
  def index
  	@candidates = User.joins('left join votes on votes.voter_id = users.id').pluck(:name).uniq
  end
end
