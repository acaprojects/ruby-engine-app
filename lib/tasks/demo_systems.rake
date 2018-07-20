# Usage: rake demo:system1
# Creates a demo zone, system, device for use with /meeting UI

namespace :demo do
  desc 'Creates a demo zone, system, device for use with /meeting UI'
  task(:bookings => :environment)  do |task|
    zoneName  = 'Demo Systems'
    systemName  = 'Demo Booking System'
    logics    = ['ACA Demo Logic']
    supportURL  = "https://engine-url/bookings/#/"
    ews_room = 'testroom1@acaprojects.com'

    #Create the Zone
    z=::Orchestrator::Zone.find_by_name zoneName
    if z
      puts "Zone exists: #{zoneName}"
    else
      z=::Orchestrator::Zone.new
      z.name = zoneName
      z.save
      puts "Zone created: #{zoneName}"
    end

    #Create the System
    sys = ::Orchestrator::ControlSystem.find_by_name systemName
    if sys
      puts "System exists: #{systemName}"
    else
      node_id = ::Orchestrator::Remote::NodeId
      sys = ::Orchestrator::ControlSystem.new
      sys.name =  systemName
      sys.zones = [z.id]
      sys.edge_id = node_id
      sys.email = ews_room
      sys.bookable = true
      sys.save
      sys.support_url = supportURL + sys.id
      #sys.description = "Demo room with Booking Panel UI"
      sys.save
      puts "System created: #{systemName}"

      #Import the Bookings Driver
      dep = ::Orchestrator::Dependency.new
      dep.name =      "Exchange Room Bookings"
      dep.role =      "logic"
      dep.class_name =  "::Aca::ExchangeBooking"
      dep.module_name =   "Bookings"
      dep.settings = {
          'use_act_as' => true, 
          'ews_creds' => [
          'https://outlook.office365.com/EWS/Exchange.asmx',
          'user@email.com',
          'password'
      ]}
      dep.save
      puts "Driver created: #{dep.name}"

      #Add the Logic to the System
      mod = ::Orchestrator::Module.new
      mod.dependency_id =   dep.id
      mod.control_system_id = sys.id
      mod.edge_id =       node_id
     
      mod.save
      sys.modules = [mod.id]
      sys.save
      puts "#{dep.name} added to #{sys.name} as #{mod.id}"
    end
  end

  desc 'Creates a demo zone, system, device for use with /meeting UI'
  task(:system1 => :environment)  do |task|
    zoneName  = 'Demo System'
    systemName  = 'Frontend Dev System'
    logics    = ['ACA Demo Logic']
    supportURL  = "http://localhost:#{ENV['DEV_PORT']}/#/"

    #Create the Zone
    z=::Orchestrator::Zone.find_by_name zoneName
    if z
      puts "Zone exists: #{zoneName}"
    else
      z=::Orchestrator::Zone.new
      z.name = zoneName
      z.save
      puts "Zone created: #{zoneName}"
    end

    #Create the System
    sys = ::Orchestrator::ControlSystem.find_by_name systemName
    if sys
      puts "System exists: #{systemName}"
    else
      node_id = ::Orchestrator::Remote::NodeId
      sys = ::Orchestrator::ControlSystem.new
      sys.name =  systemName
      sys.zones = [z.id]
      sys.edge_id = node_id
      sys.save
      sys.support_url = supportURL + sys.id
      sys.description = "[demo-ui](https://github.com/acaprojects/demo-ui) has been cloned into your setup-dev folder. To start building, `cd demo-ui` then `npm install` then `gulp serve` and click the Support URL above."
      sys.save
      puts "System created: #{systemName}"

      #Import the Logic Driver
      dep = ::Orchestrator::Dependency.new
      dep.name =      "ACA Demo Logic"
      dep.role =      "logic"
      dep.class_name =  "::Aca::DemoLogic"
      dep.module_name =   "Demo"
      dep.settings =    {"joiner_driver" => "System"}
      dep.save
      puts "Driver created: #{dep.name}"

      #Add the Logic to the System
      mod = ::Orchestrator::Module.new
      mod.dependency_id =   dep.id
      mod.control_system_id = sys.id
      mod.edge_id =       node_id
      mod.save
      sys.modules = [mod.id]
      sys.save
      puts "#{dep.name} added to #{sys.name} as #{mod.id}"
    end
  end
end
