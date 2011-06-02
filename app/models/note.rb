class Note < ActiveRecord::Base

  VALID_SYSTEM_NOTE_TYPES = ["Administrative","Problem Description","Live chat","Notification Sent","Web Update"]
  VALID_USER_NOTE_TYPES = ["Chat","Action Plan","Consult","Customer Contacted","Initial Response","L2 Consult","Research","Sent Email","Webex"]
  VALID_VISIBILITY_VALUES = ["Internal","Public"]  
  belongs_to :service_request
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by'
  validates_inclusion_of :note_type, 
                          :in => VALID_SYSTEM_NOTE_TYPES|VALID_USER_NOTE_TYPES,
                          :allow_nil => false,
                          :message => "must be valid note type"

  validates_inclusion_of :visibility, 
                          :in => VALID_VISIBILITY_VALUES,
                          :allow_nil => false,
                          :message => "must be #{VALID_VISIBILITY_VALUES.join(' or ')}"

  named_scope :recent, lambda { |sr| {:conditions => {"notes.service_request_id" => sr}, :order => "notes.updated_at DESC", :limit => 10}}

  def valid_user_note_types
    VALID_USER_NOTE_TYPES
  end
  
  def clean_body
    # 'PROBLEM DESCRIPTION: ------------------------------------ When users in our Tokyo'
    body.gsub(/[ ]*PROBLEM DESCRIPTION[:\-\s]*|BUSINESS IMPACT[:\-\s]*|ENVIRONMENT INFORMATION[:\-\s]*|(\s)/i,' ').strip    
  end
  
  
end
