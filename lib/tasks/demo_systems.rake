# Usage: rake demo:system1
# Creates a demo zone, system, device for use with /meeting UI

namespace :demo do
	desc 'Creates a demo zone, system, device for use with /meeting UI'
	task(:system1) do |task|
		ZoneName	= 'Demo Zone'
		SystemName	= 'Demo System'
		Logics		= ['aca meeting rm logic']
		SupportURL	= 'http://localhost:8888/meeting/#/?ctrl='

		#Create the Zone
		z = ::Orchestrator::Zone.new
		z.name = ZoneName
		z.save

		#Create the System
		sys = ::Orchestrator::ControlSystem.find_by_name sys_name
        if sys
            puts "System exists: #{sys_name}"
        else
            sys = ::Orchestrator::ControlSystem.new
	        sys.name =  SystemName
	        sys.zones = [z.id]
	        sys.edge_id = ::Orchestrator::Remote::NodeId
	        sys.support_url = SupportURL + sys.id
	        sys.save
    	end

		#Import the Logic Driver
		#Add the Logic

	end
end
