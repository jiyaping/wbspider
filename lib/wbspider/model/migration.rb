# encoding:utf-8

module Wbspider
  class AddWeibo < ActiveRecord::Migration
    def self.up
      create_table :weibos do |t|
        t.string  :weibo_id
        t.string  :nickname
        t.string  :user_id
        t.string  :nick_href
        t.string  :is_vip
        t.string  :is_donate 
        t.string  :content
        t.string  :content_pic 
        t.string  :attitude
        t.string  :attitude_href
        t.string  :report
        t.string  :report_href
        t.string  :comment
        t.string  :comment_href
        t.string  :favorite_href
        t.string  :generate_time
        t.string  :generate_by
        
        t.string  :repost_id            # if this field not null, then it's a repost
        t.string  :original_nickname
        t.string  :original_nickname_href
        t.string  :original_is_vip
        t.string  :original_is_donate 
        t.string  :original_content 
        t.string  :original_pic
        t.string  :original_attitude
        t.string  :original_report
        t.string  :original_comment
      end
    end

    def self.down
      drop_table :weibos
    end
  end

  class AddComment < ActiveRecord::Migration
    def self.up
      create_table :comments do |t|
        t.integer :weibo_id
        t.string  :comment_id
        t.string  :nickname
        t.string  :nickname_href
        t.string  :content
        t.string  :spam_href
        t.string  :attitude
        t.string  :attitude_href
        t.string  :reply_href
        t.string  :comment_time
        t.string  :comment_by
      end
    end

    def self.down
      drop_table :comments
    end
  end

  class AddProfile < ActiveRecord::Migration
    def self.up
      create_table :profiles do |t|
        t.string  :original_id
        t.string  :nickname
        t.string  :vipinfo
        t.string  :gender
        t.string  :area
        t.string  :birthday
        t.string  :sex_orientation
        t.string  :vipinfo_detail
        t.string  :summary
        t.string  :pic_href
        t.string  :education
        t.string  :work
        t.string  :tag
      end
    end

    def self.down
      drop_table :profiles
    end
  end

  class AddRelation < ActiveRecord::Migration
    def self.up
      create_table :relations do |t|
        t.string  :user_id
        t.string  :user_nick
        t.string  :follower_id
        t.string  :follower_nick
        t.string  :follow_time
        t.string  :valid_flag
        t.string  :follow_by
      end
    end

    def self.down
      drop_table :relations
    end
  end

  class AddExperience < ActiveRecord::Migration
    def self.up
      create_table :experiences do |t|
        t.string  :user_id
        t.string  :content
        t.string  :start_time
        t.string  :end_time
        t.string  :experience_type
      end
    end

    def self.down
      drop_table :experiences
    end
  end

  class AddPage < ActiveRecord::Migration
    def self.up
      create_table :pages do |t|
        t.string      :original_id
        t.string      :nickname
        t.string      :url
        t.string      :page_content, :text=> true
        t.integer     :page_num
        t.integer     :page_type  #1. weibos 2. profiles 3.followers 4.fans
        t.string      :spiderid
        t.datetime    :page_time
        t.integer     :parsered
      end
    end

    def self.down
      drop_table :pages
    end
  end

  class AddDone < ActiveRecord::Migration
    def self.up
      create_table :dones do |t|
        t.string  :value
      end
    end

    def self.down
      drop_table :dones
    end
  end
end