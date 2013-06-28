require "aws-sdk"
require "mortar/helpers"

module Mortar
  module S3Tools
    module Lib
      NO_AWS_KEYS_ERROR_MESSAGE = <<EOF
Please specify your amazon AWS access key via environment variable AWS_ACCESS_KEY
and your AWS secret key via environment variable AWS_SECRET_KEY, e.g.:

  export AWS_ACCESS_KEY="XXXXXXXXXXXX"
  export AWS_SECRET_KEY="XXXXXXXXXXXX"
EOF

      def self.getS3()
        if not ENV["AWS_ACCESS_KEY"] and ENV["AWS_SECRET_KEY"]
          Mortar::Helpers.error(NO_AWS_KEYS_ERROR_MESSAGE)
        end

        AWS.config({
          :access_key_id => ENV["AWS_ACCESS_KEY"],
          :secret_access_key => ENV["AWS_SECRET_KEY"]
        })
        return AWS::S3.new
      end
    end
  end
end
