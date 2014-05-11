require 'spec_helper'

describe Dock0 do
  describe '#new' do
    it 'creates Image objects' do
      expect(Dock0.new).to be_an_instance_of Dock0::Image
    end
  end

  describe Dock0::Image do
    it 'loads stacked config files' do
      image = Dock0::Image.new('examples/alpha.yml', 'examples/beta.yml')
      result = { 'foo' => 'override', 'test' => 5, 'other' => 6 }
      expect(image.config).to eql result
    end
    it 'has a timestamp' do
      expect(Dock0::Image.new.stamp).to match(/\d{4}-\d{2}-\d{2}-\d{4}/)
    end
  end
end
