class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :firstname, :lastname, :locale, :password, :password_confirmation
  
  attr_accessor :password
  before_save :prepare_password
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  
  named_scope :active, {:conditions => {"users.is_deleted" => false}}
  named_scope :active_admin, {:conditions => ["users.is_admin=? and users.is_deleted=?", true, false]}
  named_scope :active_normal, {:conditions => ["users.is_admin=? and users.is_deleted=?", false, false]}
  named_scope :only_ids, {:select => "DISTINCT users.id"}
  named_scope :limit, lambda { |limit| {:limit => limit} unless limit.nil? or limit < 1}
  
  
  has_many :bookmarks
  
  def fullname
    [firstname,lastname].join(' ')
  end
  
  def mark_as_deleted
    self.is_deleted = true
    save
  end
  
  def recover
    self.is_deleted = false
    save
  end

  # login can be either username or email address
  def self.authenticate(login, pass)
    # logger.info("Authenticating with login=#{login} & pass=#{pass}")
    user = active.find_by_username(login.downcase) || find_by_email(login)
    # logger.info("Found user #{user.inspect}") if user
    return user if user && user.matching_password?(pass)
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end