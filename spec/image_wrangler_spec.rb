require 'spec_helper'

describe Gatling::ImageWrangler do

  class Point
    attr_accessor :x, :y
  end

  class Size
    attr_accessor :width, :height
  end

  it 'should get the position of the css element' do

    #Overiding the stupid public method :y of YAML module

    location = Point.new
    location.x = 1
    location.y = 2

    size = Size.new
    size.width = 100
    size.height = 200

    mock_element = mock
    mock_element.stub(:native).and_return(mock_element)
    mock_element.stub(:location).and_return(location)
    mock_element.stub(:size).and_return(size)

    position = Gatling::ImageWrangler.get_element_position(mock_element)

    position[:x].should eql(1)
    position[:y].should eql(2)
    position[:width].should eql(100)
    position[:height].should eql(200)
  end

  it 'should reset the offset so 0,0 coordinate of the cropped image is at the top left' do
    image = mock
    element = mock
    cropped_image = mock
    coordinate = {
        :x => 0,
        :y => 10,
        :width => 100,
        :height => 200,
    }

    Gatling::ImageWrangler.stub(:get_element_position).and_return(coordinate)
    image.should_receive(:crop).with(coordinate[:x], coordinate[:y], coordinate[:width], coordinate[:height], true).and_return(cropped_image)

    Gatling::ImageWrangler.crop_element(image, element)
  end
end