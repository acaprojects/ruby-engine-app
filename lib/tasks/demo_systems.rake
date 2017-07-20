# Usage: rake demo:system1
# Creates a demo zone, system, device for use with /meeting UI

namespace :demo do
	desc 'Creates a demo zone, system, device for use with /meeting UI'
	task(:system1 => :environment)  do |task|
		zoneName	= 'Demo Zone'
		systemName	= 'Demo System'
		logics		= ['aca meeting rm logic']
		supportURL	= "http://localhost:#{WWW_PORT}/meeting/#/?ctrl="

		#Create the Zone
		z=::Orchestrator::Zone.find_by_name zoneNamec
		if z
			puts "Zone exists: #{zoneName}"
		else
			z=::Orchestrator::Zone.new
			z.name = zoneName
			z.save
		end

		#Create the System
		sys = ::Orchestrator::ControlSystem.find_by_name systemName
        if sys
            puts "System exists: #{systemName}"
        else
            sys = ::Orchestrator::ControlSystem.new
	        sys.name = 	systemName
	        sys.zones = [z.id]
	        sys.edge_id = ::Orchestrator::Remote::NodeId
	        sys.support_url = supportURL + sys.id
	        sys.save
    	end

		#Import the Logic Driver
		#Add the Logic

	end
end
