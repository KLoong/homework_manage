#encoding: utf-8
class Micropost < ActiveRecord::Base
  attr_protected :authentications
  has_many :reply_microposts,:dependent => :destroy
  belongs_to :school_class
  has_many :messages, :dependent => :destroy
  USER_TYPES = {:TEACHER => 0, :STUDENT => 1}
  USER_TYPES_NAME = {0 => '教师', 1 => '学生'}
  PER_PAGE = 5

  #获取班级的microposts
  def self.get_microposts school_class, page, user_id=nil
    base_sql = "select m.id micropost_id, m.user_id, m.user_types, m.content, m.created_at,
                m.reply_microposts_count, u.name, u.avatar_url  from microposts m
                inner join users u on u.id = m.user_id "
    condition_sql = " where school_class_id = ? "
    params_arr = ["", school_class.id]
    if user_id
      condition_sql += " and m.user_id = ? "
      params_arr << user_id
    end
    condition_sql += " order by m.created_at desc "
    params_arr[0] = base_sql + condition_sql
    microposts = Micropost.paginate_by_sql(params_arr, :per_page => PER_PAGE, :page => page)
    return_info = {:page => page, :pages_count => microposts.total_pages, :details_microposts => microposts}
  end

  #获取我关注的消息的micropost_id
  def self.get_follows_id microposts, user_id
    ids = microposts[:details_microposts].map(&:micropost_id)
    where_sql = "("
    ids.each_with_index do |e,index|
      where_sql += "," if index > 0
      where_sql += e.to_s
    end
    where_sql += ")"
    if ids.length == 0
      follow_microposts_id = []
    else
      follow_microposts_id = FollowMicropost.select("micropost_id").where("user_id = #{user_id} and micropost_id in #{where_sql}").map(&:micropost_id)
    end
  end
end