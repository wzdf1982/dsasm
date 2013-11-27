class Question < ActiveRecord::Base
  belongs_to :activity

  has_many :answers
  has_many :responses, :through => :answers

  serialize :default_answers
end
