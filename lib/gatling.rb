require 'RMagick'
require 'capybara'
require 'capybara/dsl'

require 'gatling/config'
require 'gatling/image'
require 'gatling/comparison'
require 'gatling/capture_element'


#TODO: Helpers for cucumber
#TODO: Make directories as needed

module Gatling

  class << self

    def matches?(expected_reference_filename, actual_element)

      expected_reference_file = (File.join(Gatling::Configuration.path(:reference), expected_reference_filename))

      if ENV['GATLING_TRAINER']
        raise 'GATLING_TRAINER has been depreciated. Gatling will now create reference files where ones are missing. Delete bad references and re-run Gatling to re-train'
      end  

      if !File.exists?(expected_reference_file)
        actual_image = Gatling::ImageFromElement.new(actual_element, expected_reference_filename)
        save_image_as_reference(actual_image)
        return true
      else
        reference_file = Gatling::ImageFromFile.new(expected_reference_filename)
        comparison = compare_until_match(actual_element, reference_file, Gatling::Configuration.max_no_tries)
        matches = comparison.matches?
        if !matches
          comparison.actual_image.save(:candidate)
          diff_image = comparison.diff_image
          save_image_as_diff(diff_image)
          raise Gatling::MatchError.new(
                  "element did not match #{diff_image.file_name}. " +
                    "A diff image: #{diff_image.file_name} was created in " +
                    "#{diff_image.path(:diff)} " +
                    "A new reference #{diff_image.path(:candidate)} can be used to fix the test", comparison)
        end
        matches
      end
    end

    def compare_until_match actual_element, reference_file, max_no_tries = Gatling::Configuration.max_no_tries, sleep_time = Gatling::Configuration.sleep_between_tries
      try = 0
      match = false
      expected_image = reference_file
      comparison = nil
      while !match && try < max_no_tries
        actual_image = Gatling::ImageFromElement.new(actual_element, reference_file.file_name)
        comparison = Gatling::Comparison.new(actual_image, expected_image)
        match = comparison.matches?
        if !match
          sleep sleep_time
          try += 1
          #TODO: Send to logger instead of puts
          puts "Tried to match #{try} times"
        end
      end
      comparison
    end

    def save_image_as_diff(image)
      image.save(:diff)
    end

    def save_image_as_candidate(image)
      image.save(:candidate)
      raise "The design reference #{image.file_name} does not exist, #{image.path(:candidate)} " +
      "is now available to be used as a reference. Copy candidate to root reference_image_path to use as reference"
    end

    def save_image_as_reference(image)
      if image.exists?
        puts "#{image.path} already exists. reference image was not overwritten. please delete the old file to update reference"
      else
        image.save(:reference)
        puts "Saved #{image.path} as reference"
      end
    end

    def config(&block)
      begin
        config_class = Gatling::Configuration
        raise "No block provied" unless block_given?
        block.call(config_class)
      rescue
         raise "Config block has changed. Example: Gatling.config {|c| c.reference_image_path = 'some/path'}. Please see README"  
      end   
    end

  end

  class MatchError < RuntimeError
    attr_reader :message, :comparison

    def initialize(message, comparison)
      @message = message
      @comparison = comparison
    end

  end
end
