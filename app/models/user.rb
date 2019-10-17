class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  #フォロー機能の追記
  #followings＝フォローしているユーザーたち
  #followers＝フォローされているユーザーたち
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  #お気に入り機能の追記登録した投稿
  has_many :microposts #複数のmicropostsモデルに関連づけ
  has_many :favorites 
  has_many :favposts, through: :favorites, source: :micropost
 
  #他のユーザーをフォローする
  def follow(other_user)
    unless self == other_user #フォローしようとしているother_userが自分ではないかを検証
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  #他のユーザーをアンフォローする
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  #すでにフォローしているか？
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  #投稿をお気に入りする
  def like(micropost)
    favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  #投稿のお気に入りを外す
  def unlike(micropost)
    favorite = favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  #すでにお気に入りしているか？
  def favpost?(micropost)
    self.favposts.include?(micropost)
  end

end
