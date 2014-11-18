require 'spec_helper'
require 'fileutils'

describe Dock0 do
  describe '#new' do
    it 'creates Image objects' do
      expect(Dock0.new).to be_an_instance_of Dock0::Image
    end
  end

  describe Dock0::Image do
    let(:image) { Dock0::Image.new 'spec/examples/image.yml' }

    describe '#run' do
      it 'runs a command' do
        expect(image.run('echo "hello"')).to eql "hello\n"
      end
      it 'raises if the command fails' do
        expect { image.run('dasdks') }.to raise_error RuntimeError
      end
    end
  end
end
