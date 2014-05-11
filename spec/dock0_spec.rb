require 'spec_helper'

describe Dock0 do
  describe '#new' do
    it 'creates Image objects' do
      expect(Dock0.new).to be_an_instance_of Dock0::Image
    end
  end

  describe Dock0::Image do
    let(:image) { Dock0::Image.new 'spec/examples/image.yml' }

    it 'loads stacked config files' do
      config_image = Dock0::Image.new(
        'spec/examples/alpha.yml', 'spec/examples/beta.yml'
      )
      result = { 'foo' => 'override', 'test' => 5, 'other' => 6 }
      expect(config_image.config).to eql Dock0::DEFAULT_CONFIG.merge(result)
    end
    it 'has a timestamp' do
      expect(Dock0::Image.new.stamp).to match(/\d{4}-\d{2}-\d{2}-\d{4}/)
    end

    describe '#run' do
      it 'runs a command' do
        expect(image.run('echo "hello"')).to eql 'hello'
      end
      it 'raises if the command fails' do
        expect { image.run('dasdks') }.to raise_error RuntimeError
      end
    end
  end
end
