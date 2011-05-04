class UserMailer < ActionMailer::Base
  default :from => APP_CONFIG.email_from_address

  def new_product(product)
    # send mail to administrators
    @recipients = User.where(:receive_admin_email => true)
    @product = product
    mail :to => @recipients.map(&:email)
  end

  def product_approval_request(product)
    # send mail to administrators
    @recipients = User.where(:receive_admin_email => true)
    @product = product
    mail :to => @recipients.map(&:email)
  end

  def product_approved(product, approver)
    @product = product
    @approver = approver
    mail :to => product.publisher.email
  end

  def product_blocked(product, blocker)
    @product = product
    @blocker = blocker
    mail :to => product.publisher.email
  end
end
