module Gatling
  module ImageWrangler

    def self.get_element_position element
      element = element.native
      position = Hash.new{}
      position[:x] = element.location.x
      position[:y] = element.location.y
      position[:width] = element.size.width
      position[:height] = element.size.height
      position
    end

    def self.crop_element image, element_to_crop
      position = get_element_position(element_to_crop)
      # reset the offset data so the 0,0 coordinate is now at the top left of the cropped image
      @cropped_element = image.crop(position[:x], position[:y], position[:width], position[:height], true)
    end




  end
end
