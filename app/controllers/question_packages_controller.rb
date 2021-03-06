class QuestionPackagesController < ApplicationController
  require 'will_paginate/array'

  def index
    respond_to do |f|
      #分享题目的分页
      f.js{
        @question_pack = QuestionPackage.find_by_id(params[:question_package_id])
        @question = Question.find_by_id(params[:question_id])
        @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq inner join users u on sq.user_id = u.id").paginate(:page => params[:page], :per_page => 5)
      }
      f.html
    end
  end
  
  def new
    @question_pack = QuestionPackage.new
  end

  #新建题包其中第一个答题第三步之后，建题包，建答题
  def create
    question_type, new_or_refer, cell_id, episode_id, question_pack_id = params[:question_type], params[:new_or_refer], params[:cell_id], params[:episode_id], params[:question_pack_id]
    school_class_id = current_teacher.last_visit_class_id if current_teacher
    status = 0
    QuestionPackage.transaction do
      if question_pack_id.present?
        @question_pack = QuestionPackage.find_by_id(question_pack_id)
      else
        @question_pack = QuestionPackage.create(:school_class_id => school_class_id)
      end
      if @question_pack
        @question = @question_pack.questions.create({:cell_id => cell_id, :episode_id => episode_id, :types => question_type.to_i})
      else
        status =  1
      end
    
      if status ==0
        if new_or_refer == "0"
          render :partial => "questions/new_branch"
        else
          @share_questions = ShareQuestion.find_by_sql("select u.name user_name, sq.* from share_questions sq inner join users u on sq.user_id = u.id where sq.types=#{question_type.to_i}").paginate(:page => params[:page], :per_page => 5)
          render :partial =>"questions/new_reference"
        end
      else
        render :text => "error"
      end
    end
  end

  def update
    question_package = QuestionPackage.find_by_id(params[:id])
    if question_package && params[:question_package][:name]
      question_package.update_attribute(:name, params[:question_package][:name])
    end
    redirect_to question_package_questions_path(question_package)
  end

  def render_new_question
    @question_pack_id = params[:id] if params[:id].present? && params[:id] != 'undefined'
    render :partial => "three_step"
  end
  
end