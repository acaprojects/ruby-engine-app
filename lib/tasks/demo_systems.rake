# Usage: rake demo:system1
# Creates a demo zone, system, device for use with /meeting UI

namespace :demo do
  desc 'Creates a demo zone, system, device for use with /meeting UI'
  task(:system1 => :environment)  do |task|
    zoneName  = 'Demo Zone'
    systemName  = 'Demo System'
    logics    = ['ACA Demo Logic']
    supportURL  = "http://localhost:#{ENV['WWW_PORT']}/demo/#/?ctrl="

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
      sys.description = "For front-end dev, run the [demo-ui kit](https://github.com/acaprojects/demo-ui) on your PC\n[Markdown Format](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) supported here"
      sys.save
      puts "System created: #{systemName}"

      #Import the Logic Driver
      dep = ::Orchestrator::Dependency.new
      dep.name =      "ACA Demo Logic"
      dep.role =      "logic"
      dep.class_name =  "::Aca::DemoLogic"
      dep.module_name =   "System"
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
