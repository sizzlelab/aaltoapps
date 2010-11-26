module ApplicationHelper
  def list_platforms
    Platform.find(:all)
  end
end
