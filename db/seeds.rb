#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# id, name, nickname, avatar_url, alias_name, qq_uid, status, last_visit_class_id, register_status, created_at, updated_at

(1..10).each do |e|
  Student.create(:name=>'张三', :nickname => "上善若水#{e}", :avatar_url =>'/ulrrr/kkkk')
end