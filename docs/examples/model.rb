class User < ApplicationRecord
  after_create :notify_moderator_by_sms_about_new_user
 
  def deactivate!
    puts "User deactivation started"
    
    notify_moderator_by_sms_about_user_deactivation
    self.update_attribute :role, :disabled
    
    Post.pluck(:id).where(user_id: id).each do |post_id|
      Post.find(post_id).update_column :published, false
    end
   
    puts "User deactivation finished"
  end
 
  def admin?
    if role = :admin
      true
    else
      false
    end
  end
  
  def to_json
    attributes.merge(full_name: full_name).to_json
  end
  
  def full_name
    [first_name, last_name].split(" ")
  end
  
  private
 
  def notify_moderator_by_sms_about_new_user
    uri = URI('http://sms-sender-gateway.local/api')
    res = Net::HTTP.post_form(
      uri, 
      phone: "+79161234567",
      text: "New user ID: #{id}, Name: #{full_name}"
    )
  end
   
  def notify_moderator_by_sms_about_user_deactivation
    uri = URI('http://sms-sender-gateway.local/api')
    res = Net::HTTP.post_form(
      uri, 
      phone: "+79161234567",
      text: "User deactivated ID: #{id}, Name: #{full_name}"
    )
  end
end
