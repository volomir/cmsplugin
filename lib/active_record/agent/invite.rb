module ActiveRecord #:nodoc:
  module Agent
    # Support for Agent for being invited.
    #
    # Invitations can be made to the Application, or/and to a particular Stage and Role
    #
    module Invite
      class << self
        # All classes supporting Invitation
        def classes
          ActiveRecord::Agent.classes.select{ |a| a.agent_options[:invite] }
        end

        # Find all Agent instances by invitation key
        def find_all(key)
          classes.map{ |klass|
            klass.send "find_all_by_#{ klass.agent_options[:invite] }", key
          }.flatten.uniq
        end

        def included(base) #:nodoc:
          base.class_eval do
            after_create "invitations_to_performances"
          end
        end
      end

      private

      # Create a Performance for each Invitation of this Agent
      def invitations_to_performances #:nodoc:
        key = send(agent_options[:invite])

        # FIXME: Probably Agent doesn't want to accept all invitations
        Invitation.find_all_by_email(key).map(&:accept!)
      end
    end
  end
end
