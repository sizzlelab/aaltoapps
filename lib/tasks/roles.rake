# rake tasks for granting and revoking administrator roles for users
namespace :role do
  {
    :grant  => { :value => true,  :desc => 'Grant admin role' },
    :revoke => { :value => false, :desc => 'Revoke admin role' },
  }.each do |name, opts|
    namespace name do
      desc opts[:desc]
      task :admin, [:key] => :environment do |t, args|
        # find user using either local id or asi_id
        user = begin
          User.find(Integer(args[:key]))
        rescue ArgumentError, ActiveRecord::RecordNotFound
          begin
            User.find_by_asi_id!(args[:key])
          rescue ActiveRecord::RecordNotFound
            raise ActiveRecord::RecordNotFound.new("Couldn't find User with id or asi_id = #{args[:key]}")
          end
        end

        user.is_admin = opts[:value]
        user.save!
        puts 'Ok'
      end
    end
  end
end
