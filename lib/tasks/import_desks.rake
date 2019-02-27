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
#           $ rake import_desks:csv['<csv file path>']
#           # Persist updates to the db
#           $ rake import_desks:csv['<csv file path>','create!']
#
# Safe to run multiple times if required to correct mistakes etc. All systems
# and devices will be updated as required and newly defined devices added.

require 'csv'

namespace :import_desks do
    EDGE = 'edge-EFx0N7sivB'

    ZONES = {
        # Org
        ACA: 'zone-m5VWaO26-6',

        # Building
        'Building' => 'zone-m5VXfu-wiB',

        # Levels
        'Level 27' => 'zone-m5VYOIO-T1',
        'Level 28' => 'zone-m4y~zmX439',
    }

    DEPENDENCIES = {
        :logic => {
            :o365_bookings => 'dep-m5VbBT3ACe'
        }
    }.freeze

    # Columns relevant to systems
    System = Struct.new :building, :engine_svg_desk_id, :desk_name, :level, :o365_mailbox, :name do
        def id
          "sys-#{name.gsub(/\s+/, "")}".downcase # remove spaces from the desk name
        end

        def email
          o365_mailbox
        end

        def settings
          set = {}
          set[:desk] = true
          set[:map_id] = engine_svg_desk_id
          puts "settings"
          puts set
          set
        end

        # zones should be added in order of level, building and then org
        def zones
            [
                ZONES["Level #{level}"],
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
            sys.bookable = true
            sys.edge_id = EDGE
            sys.capacity = 1
            sys.settings = settings

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
