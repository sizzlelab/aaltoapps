desc "Remove expired sessions. This should be run from a cronjob at regular intervals."
task :expire_sessions => :environment do |t, args|
  ActiveRecord::SessionStore::Session.delete_all(
    ['updated_at < ?', APP_CONFIG.session_expiration.minutes.ago] )
end
