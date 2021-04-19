class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :requested_friendships, foreign_key: 'requester_id', class_name: 'Friendship'
  has_many :received_friendships, foreign_key: 'receiver_id', class_name: 'Friendship'

  def friends
    received_friendships.map { |fr| fr.requester if fr.status }.compact
  end

  def pending_friends
    requested_friendships.map { |fr| fr.receiver unless fr.status }.compact
  end

  def friend_requests
    received_friendships.map { |fr| fr.requester unless fr.status }.compact
  end

  def confirm_friend(user, current_user)
    friendship = received_friendships.find { |fr| fr.requester == user }
    friendship.status = true
    friendship.save
    Friendship.create!(receiver_id: user.id, requester_id: current_user.id, status: true)
  end

  def friend?(user)
    friends.include?(user)
  end
end
