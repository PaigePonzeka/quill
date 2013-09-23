class Chapter::BaseController < ApplicationController
  before_filter :find_assignment, except: ['verify', 'verify_status']
  layout 'chapter_test'

  def find_assignment
    @body_class = ''
    @chapter = Chapter.find(params[:chapter_id])
    @user = if current_user.present? then current_user else temporary_user end

    @score = if @user.started_chapters.include?(@chapter)
      @user.scores.for_chapter(@chapter)
    else
      ClassroomChapter.temporary_score(@chapter, user: @user)
    end

    @chapter_test = ChapterTest.new(self)
  end

private

  def temporary_user
    unless user = User.unscoped.find_by_id(session[:temporary_user_id])
      user = User.create! role: 'temporary'
      session[:temporary_user_id] = user.id
    end

    user
  end
end