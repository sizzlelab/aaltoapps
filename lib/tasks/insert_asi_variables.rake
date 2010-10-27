task :insert_asi_variables => :environment do |t, args|
  if !args['APPNAME'] || !args['PASSWORD']
    puts 'Not enough parameters. APPNAME and PASSWORD needed, SERVER is optional'
    return false
  end

  app_name = Variable.find_by_key('asi_app_name')
  app_password = Variable.find_by_key('asi_app_password')
  
  if !app_name
    Variable.create!(:key => 'asi_app_name', :value => args['APPNAME'])
  else
    app_name.value = args['APPNAME']
    app_name.save!
  end
  
  if !app_password
    Variable.create!(:key => 'asi_app_password', :value => args['PASSWORD'])
  else
    app_password.value = args['PASSWORD']
    app_password.save!
  end
  
  if args['SERVER']
    server = Variable.find_by_key('asi_server')
    if server
      server.value = args['SERVER']
    else
      Variable.create(:key => 'asi_server', :value => args['SERVER'])
    end
  end
end
