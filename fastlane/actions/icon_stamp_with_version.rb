module Fastlane
  module Actions
    module SharedValues
      ICON_STAMP_WITH_VERSION_CUSTOM_VALUE = :ICON_STAMP_WITH_VERSION_CUSTOM_VALUE
    end

    class IconStampWithVersionAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter Label: #{params[:label]}"
        UI.message "Parameter icon path: #{params[:icon_path]}"

        sh "fastlane/actions/version_icon_stamp.sh -p #{params[:icon_path]} -l \"#{params[:label]}\""

        # Actions.lane_context[SharedValues::ICON_STAMP_WITH_VERSION_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Stamps the app's icon with the version"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :icon_path,
                                       env_name: "FL_ICON_STAMP_WITH_VERSION_ICON_PATH",
                                       description: "Path for the icons",
                                       is_string: true,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :label,
                                       env_name: "FL_ICON_STAMP_WITH_VERSION_LABEL",
                                       description: "The label to put to the icon",
                                       is_string: true,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['ICON_STAMP_WITH_VERSION_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
      end

      def self.authors
        ["davidkovaccs"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
