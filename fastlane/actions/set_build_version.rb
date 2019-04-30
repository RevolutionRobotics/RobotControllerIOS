module Fastlane
  module Actions
    module SharedValues
      SET_BUILD_VERSION_BUILD_NUMBER = :SET_BUILD_VERSION_BUILD_NUMBER
    end

    class SetBuildVersionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter Plist path: #{params[:plist_path]}"
        UI.message "Parameter Include branch name: #{params[:include_branch_name]}"

        version = sh "git rev-list HEAD --count"
        version = version.chomp
        
        if (params[:include_branch_name])
          version = version + "-" + Actions::GitBranchAction.run(nil)[0,2]
        end

        Actions::SetInfoPlistValueAction.run(path: params[:plist_path], key: 'CFBundleVersion', value: version)

        Actions.lane_context[SharedValues::SET_BUILD_VERSION_BUILD_NUMBER] = version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set build number to the number of commits in the branch"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to set the build number of an iOS app to the number of git commits you have in the current branch"
      end

      def self.available_options
        # Define all options your action supports. 
        [
          FastlaneCore::ConfigItem.new(key: :include_branch_name,
                                       env_name: "FL_SET_BUILD_VERSION_INCLUDE_BRANCH_NAME",
                                       description: "Should the build number include branch name or not",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_SET_BUILD_VERSION_PLIST_PATH",
                                       description: "Plist path",
                                       is_string: true)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        [
          ['SET_BUILD_VERSION_BUILD_NUMBER', 'Build number set by the action']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["davidkovaccs"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
