class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

  validates :email, presence: true,
                    length: {minium: Settings.validates.min_length,
                             maximum: Settings.validates.max_length},
                    format: {with: Settings.regex.email_regex},
                    uniqueness: {case_sensitive: false}

  validates :name, presence: true,
                   length: {minium: Settings.validates.min_length,
                            maximum: Settings.validates.max_length}

  has_secure_password
  validates :password, presence: true,
                       length: {minimum: Settings.validates.password_min_length},
                       allow_nil: true

  class << self
    def digest string
      check = ActiveModel::SecurePassword.min_cost
      cost = check ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.blank?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_mail_activate
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
