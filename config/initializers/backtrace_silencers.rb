
Rails.backtrace_cleaner.remove_silencers!
Rails.backtrace_cleaner.add_silencer { |line| line =~ /rack|rails|middleware|active_support|action_dispatch|action_controller|abstract_controller/ }
Rails.backtrace_cleaner.add_silencer { |line| line =~ /libuv|spider-gazelle/ }
