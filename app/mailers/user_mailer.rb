class UserMailer < ActionMailer::Base
  class NoRecipients < StandardError; end

  default :from => APP_CONFIG.email_from_address

  def new_product(product)
    @product = product
    send_to_admins
  end

  def product_approval_request(product)
    @product = product
    send_to_admins
  end

  def product_approved(product, approver)
    @product = product
    @approver = approver
    mail_with_locale product.publisher
  end

  def product_blocked(product, blocker)
    @product = product
    @blocker = blocker
    mail_with_locale product.publisher
  end


  private

  # send mail to administrators
  def send_to_admins
    @all_recipients = User.where(:receive_admin_email => true)
    raise NoRecipients  if @all_recipients.blank?
    @all_recipients.group_by(&:language).each do |lang, users|
      @recipients = users
      mail_with_locale users, lang
    end
  end

  def mail_with_locale(recipients, locale=nil)
    locale = recipients.language || APP_CONFIG.fallback_locale  if !locale && recipients.respond_to?(:language)
    @locale = locale
    @product_url = product_url(@product, :locale => locale)  if @product
    mail :to => Array.wrap(recipients).map(&:email)
  end
end
