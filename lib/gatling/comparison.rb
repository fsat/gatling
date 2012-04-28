module Gatling
  class Comparison

    attr_accessor :match, :diff_image

    def initialize actual_image, expected_image
      @actual_image = actual_image
      @expected_image = expected_image
    end

    def matches?
      diff_metric = compare_image
      @match = diff_metric[1] == 0.0
    end

    def diff_image
      diff_image = compare_image.first
      Gatling::Image.new(:from_diff, diff_image)
    end

    def compare_image
      compare_images_with_same_size? ? compare_images_with_same_size : compare_images_with_different_size
    end

    def compare_images_with_same_size
      @actual_image.image.compare_channel(@expected_image.image, Magick::MeanAbsoluteErrorMetric)
    end

    def compare_images_with_different_size
      row = [@actual_image.image.rows, @expected_image.image.rows].max
      column = [@actual_image.image.columns, @expected_image.image.columns].max

      images_to_compare = [
          @actual_image,
          @expected_image,
      ].collect do |gatling_image|
        image = gatling_image.image.extent(column, row)
        image.background_color = 'white'
        image
      end

      images_to_compare.first.compare_channel(images_to_compare.last, Magick::MeanAbsoluteErrorMetric)
    end

    def compare_images_with_same_size?
      @actual_image.image.rows == @expected_image.image.rows && @actual_image.image.columns == @expected_image.image.columns
    end

  end
end