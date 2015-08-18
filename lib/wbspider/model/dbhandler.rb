# encoding : utf-8

module Wbspider
  class << self
    def create_tables(db)
      db.create_table? :pages do
        primary_key :id
        String      :original_id
        String      :nickname
        String      :url
        String      :page_content, :text=> true
        Integer     :page_num
        Integer     :page_type  #1. weibos 2. profiles 3.followers 4.fans
        String      :spiderid
        DateTime    :page_time
        Integer     :parsered
      end

      db.create_table? :dones do
        primary_key :id
        String      :value
      end

      db.create_table? :profiles do
        primary_key :id
        String  :original_id
        String  :nickname
        String  :vipinfo
        String  :gender
        String  :area
        String  :birthday
        String  :sex_orientation
        String  :vipinfo_detail
        String  :summary
        String  :pic_href
        String  :education
        String  :work
        String  :tag
      end

      db.create_table? :weibos do
        primary_key :id
        String  :weibo_id
        String  :nickname
        String  :user_id
        String  :nick_href
        String  :is_vip
        String  :is_donate 
        String  :content
        String  :content_pic 
        String  :attitude
        String  :attitude_href
        String  :report
        String  :report_href
        String  :comment
        String  :comment_href
        String  :favorite_href
        String  :generate_time
        String  :generate_by
        
        String  :repost_id            # if this field not null, then it's a repost
        String  :original_nickname
        String  :original_nickname_href
        String  :original_is_vip
        String  :original_is_donate 
        String  :original_content 
        String  :original_pic
        String  :original_attitude
        String  :original_report
        String  :original_comment
      end

      db.create_table? :relation do
        primary_key :id
        String  :user_id
        String  :user_nick
        String  :follower_id
        String  :follower_nick
        String  :follow_time
        String  :valid_flag
        String  :follow_by
      end
    end
  end
end