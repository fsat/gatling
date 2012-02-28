module Gatling
 module Configuration

    class << self

      attr_accessor 'reference_image_path', 'trainer_toggle'

      def reference_image_path
        begin
        @reference_image_path ||= File.join(Rails.root, 'spec/reference_images')
        rescue
          @reference_image_path = 'spec/reference_images'
          raise "Not using Rails? Currently defaulting to #{@reference_image_path}. Overide this by setting Gatling::Configuration.reference_image_path=[refpath]"
        end
      end

      def trainer_toggle
        @trainer_value = ENV['GATLING_TRAINER']

        case @trainer_value
          when nil
            @trainer_value = nil
          when 'true'
            @trainer_value = true
          when 'false'
            @trainer_value = false
          else
            @trainer_value = false
            puts 'Unknown GATLING_TRAINER argument. Please supply true, false or nil. DEFAULTING TO FALSE'
        end
        @trainer_toggle ||= @trainer_value ||= false
      end

    end

  end
end