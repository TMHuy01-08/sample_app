class User < ApplicationRecord
  before_save :downcase_email

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
                       if: :password

  private

  def downcase_email
    email.downcase!
  end
end
