
class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,   class_name:  "Relationship",
                                    foreign_key: "follower_id",
                                    dependent:   :destroy
  has_many :passive_relationships,  class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy 
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest

	#before_save { email.downcase! } #switched with one above it
  validates :name,  presence: true, length: { maximum: 50 }

  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i #allows multiple dots
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
										format: { with: VALID_EMAIL_REGEX },
										uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  #has secure password catches true nils at creation, this is for update (remain same)

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") # self.send but it can be omitted
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends an activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes
  def create_reset_digest
    self.reset_token   = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago #prateno pred pomalku od dva saata
  end

  # Defines a proto-feed
  # Full implementation coming later (Twitter style)
  # Past versions of the feed are commented out
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
    #Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                following_ids: following_ids, user_id: id)
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    #Micropost.where("user_id = ?", id) 
    #(user_id: "id") wasn't listed in the lesson...so
  end

  # Follows another user
  def follow(other_user)
    following << other_user #self.following practically
  end

  # Unfollows another user
  def unfollow(other_user)
    following.delete(other_user) #self.following practically
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user) #self.following practically
  end

  private

    # Converts email to lowercase
    def downcase_email
      email.downcase!
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token   = User.new_token
      self.activation_digest  = User.digest(activation_token)
    end
    #self.activation_digest here too because this method is called before_create
    #thus, there is no activation digest in the DB to update (as in
    #the remembe method for example)
end