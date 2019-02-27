# frozen_string_literal: true

# Tooling for system a device spinup from project IP address speadsheets.
#
# Usage:
#   1. export IP address spreadsheet as CSV
#   2. ensure edge, zone and dependancies have been created and id's match the
#      config below
#   3. define `FILTERS` as required to ignore specific systems or devices
#   4. Run it:
#
#           # Test parse only
#           $ rake import:csv['<csv file path>']
#           # Persist updates to the db
#           $ rake import:csv['<csv file path>','create!']
#
# Safe to run multiple times if required to correct mistakes etc. All systems
# and devices will be updated as required and newly defined devices added.

require 'csv'

namespace :import do
    EDGE = 'edge-jopZ9WhQ9d'

    ZONES = {
        # Org
        ACA: 'zone-m58jrlc-0A',

        # Building
        'Building' => 'zone-m58kmePZur',

        # Levels
        'Level 27' => 'zone-m58lUPJXcD',
        'Level 28' => 'zone-m4y~zmX439',
    }

    DEPENDENCIES = {
        :logic => {
            :o365_bookings => 'dep-m58t_Ar3-1'
        }
    }.freeze

    # Columns relevant to systems
    System = Struct.new :building, :floor_number, :room_name, :capacity, :bookable_from_aca_app, :office365_mailbox_address, :tv, :smartboard, :video_conference, :dolby_phone, :vc_dial_in_ip do
        def name
          "#{building}-Meeting-#{room_name}"
        end

        def id
          "sys-#{building}#{room_name}".downcase
        end

        def email
          office365_mailbox_address
        end

        def map_id
          room_number = room_name.to_s[/#{floor_number.to_s}(.*)/, 1] # regex capture everything after the floor number from the room name
          "#{floor_number}.#{room_number}"
        end

        def extras
          features = []
          features.push({'extra_id' => 'tv', 'extra_name' => 'TV'}) if tv == 'Yes'
          features.push({'extra_id' => 'smartboard', 'extra_name' => 'Smartboard'}) if smartboard == 'Yes'
          features.push({'extra_id' => 'video_conference', 'extra_name' => 'Video Conference'}) if video_conference == 'Yes'
          features.push({'extra_id' => 'dolby_phone', 'extra_name' => 'Dolby Phone'}) if dolby_phone == 'Yes'
          features.push({'extra_id' => 'vc_dial_in_ip', 'extra_name' => 'VC dial in IP'}) if vc_dial_in_ip == 'Yes'
          puts "features"
          puts features
          features
        end

        def settings
          set = {}
          set[:map_id] = map_id
          ext = extras
          set[:extras] = ext if !ext.empty?
          puts "settings"
          puts set
          set
        end

        def support_url
          "https://demo.aca.im/booking/#/#{id}"
        end

        # zones should be added in order of level, building and then org
        def zones
            [
                ZONES["Level #{floor_number}"],
                ZONES[building],
                ZONES[:ACA]
            ]
        end

        def to_model
            sys = Orchestrator::ControlSystem.find_by_id(id) || \
                  Orchestrator::ControlSystem.new.tap { |sys| sys.id = id }

            sys.name = name
            sys.zones = zones unless sys.zones.present?
            sys.email = email
            sys.bookable = bookable_from_aca_app == "Yes"
            sys.edge_id = EDGE
            sys.capacity = capacity
            sys.settings = settings
            sys.support_url = support_url

            puts "Contents of #{name}"
            puts sys

            sys
        end
      end

      Logic = Struct.new :type, :id_prefix do
        def id
          "mod-#{id_prefix}-#{type}"
        end

        def dependency_id
          DEPENDENCIES.dig :logic, type
        end

        def dependency
          Orchestrator::Dependency.find_by_id dependency_id
        end

        def to_model
          raise "#{type} driver not loaded" if dependency.nil?

          mod = Orchestrator::Module.find_by_id(id) || \
                Orchestrator::Module.new.tap { |mod| mod.id = id }

          mod.dependency_id = dependency_id
          mod.running = true
          mod
        end
      end

      # ------------------------------
      # Helpers

      # Re-attempting model updates in case bad things happen
      def save!(object, max_attempts = 8)
        puts "attempting to save:\n"
        puts object
        tries ||= max_attempts
        object.save!
      rescue => e
        puts "error: #{e.message} -- #{object.errors.messages}"
        if (tries -= 1) > 0
          sleep 1
          retry
        else
          puts "FAILED TO CREATE #{object}"
          return
        end
      end

      desc 'Import project IP address spreadsheet into systems and devices'
      task(:csv, [:file_name, :run_type] => [:environment]) do |_, args|
        csv_file = args[:file_name]
        do_save = args[:run_type] == 'create!'

        systems = []

        CSV.table(csv_file).each { |rec|
          systems.push(System.new(*rec.values_at(*System.members)))
        }

        puts "Found #{systems.size} systems"
        puts systems

        systems.each do |system|
            if do_save
              puts "\nSetting up #{system.name}"
            else
              puts "\nPreviewing changes for #{system.name}"
            end

            sys = system.to_model
            save!(sys) if do_save

            modules = []

            # add o365 driver
            modules << Logic.new(:o365_bookings, sys.id)

            modules.map!(&:to_model).each do |mod|
                mod.control_system_id = sys.id if mod.dependency.role == :logic
                mod.edge_id = EDGE
                save! mod if do_save
            end

            previous = sys.modules
                          .map { |id| Orchestrator::Module.find_by_id(id) }
                          .compact

            additions = modules.reject  { |m| previous.map(&:id).include?(m.id) }
            orphans   = previous.reject { |m| modules.map(&:id).include?(m.id) }
            updates   = modules - additions - previous
            unchanged = modules - additions - updates

            unless additions.empty?
              sys.modules = modules.map(&:id) | sys.modules
              sys.modules_will_change!
              save! sys if do_save
            end

            orphans.each do |mod|
              puts " - #{mod.id} (#{mod.dependency.name}) exists in system, but " \
                "not in device import - left untouched but may be safe to remove"
            end

            updates.each do |mod|
              puts " * #{mod.id} (#{mod.dependency.name}) updated"
            end

            additions.each do |mod|
              puts " + #{mod.id} (#{mod.dependency.name}) added"
            end

            puts ' ✔ no changes' if [additions, orphans, updates].all?(&:empty?)
        end

    end
end
