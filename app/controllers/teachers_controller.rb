#encoding: utf-8
require 'securerandom'
class TeachersController < ApplicationController
  #教师登陆
  def login
    email = params[:email].to_s  #需前台验证email地址
    password = params[:password].to_s
    teacher = Teacher.find_by_email email
    p teacher
    if teacher.nil?
      status = "error"
      notice = "用户不存在，请先注册！"
    else
      if teacher && teacher.has_password?(password)
        status = "success"
        notice = "登陆成功！"
      else
        status = "error"
        notice = "密码错误，登录失败！"
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师登陆
  def regist
    email = params[:email].to_s
    name = params[:name].to_s
    password = params[:password].to_s
    teacher = Teacher.find_by_email email
    if !teacher.nil?
      status = "error"
      notice = "该邮箱已被注册，换个邮箱！"
    else
      Teacher.transaction do
        teacher = Teacher.create(:name => name, :email => email, :password => password,
                      :status => Teacher::STATUS[:YES])
        password = teacher.encrypt_password
        if !teacher.nil?
          if teacher.update_attributes(:password => password)
            status = "success"
            notice = "注册完成！"
          else
            teacher.destroy
            status = "error"
            notice = "注册失败，请重新注册！"
          end
        else
          status = "error"
          notice = "注册失败，请重新注册！"
        end
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师创建班级
  def create_class
    name = params[:name]
    period_of_validity = params[:period_of_validity]
    verification_code = SecureRandom.hex(5)
    teacher_id = params[:teacher_id]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      notice = "教师不存在，不能创建班级！"
      status = "error"
    else
      if teacher.status == Teacher::STATUS[:YES]
        if teacher.school_classes.create(:name => name, :period_of_validity => period_of_validity,
                  :verification_code => verification_code)
          notice = "班级创建成功！"
          status = "success"
        else
          notice = "班级创建失败，请重新操作！"
          status = "error"
        end
      else
        notice = "教师已被禁用，无法进行操作！"
        status = "error"
      end
    end
    @info = {:status => status, :notice => notice}
    render :json => @info
  end

  #教师上传头像
  def upload_avatar
    teacher_id = params[:teacher_id]
    avatar = params[:avatar]
    teacher = Teacher.find_by_id teacher_id
    if teacher.nil?
      status = "error"
      notice = "教师不存在！"
    else
      if teacher.status == Teacher::STATUS[:YES]
      else
        status = "error"
        notice = "教师已被禁用，无法操作！"
      end
    end
    @info = {:status => status, :notice => notice}
  end
end