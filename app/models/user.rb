class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
    format: { with: VALID_EMAIL },
    length: { maximum: 255 },
    presence: true,
    uniqueness: { case_sensitive: false }
  validates :password,
    length: { minimum: 6 },
    presence: true

  has_secure_password
end