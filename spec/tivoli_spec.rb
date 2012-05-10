require './lib/tivoli'
describe Tivoli do
  before :each do
    @t = Tivoli.new String.instance_method(:upcase)
  end
  
  it 'should log' do
    i = 0
    task = proc { |*args|
      i += 1
    }
    @t.aspect :before, &task
    @t.aspect :after, &task
    "aBc".upcase
    i.should == 2
  end


  describe 'upcase' do
    it 'should be able to proxy upcase' do
      t = Tivoli.new(String.instance_method(:upcase))
      t.filter :after do |prev|
        prev.reverse
      end
      "hello".upcase.should == 'OLLEH'
    end
  end

  describe 'String#+' do
    before :each do
      @t.stop if @t
      @t = Tivoli.new(String.instance_method(:+))
    end

    it 'should log' do
      log = nil
      @t.aspect :before do |time, args, &block|
        # log stuff here or
        log = "LOG #{args}"
      end
      ("hello" + "other").should == 'helloother'
      log.should == 'LOG ["other"]'
    end

    it 'should change arguments' do
      @t.aspect :before do |time, args, &block| 
        # change arguments
        args[0].reverse!
      end
      ('hello' + 'other').should == 'hellorehto'
    end

    it 'should chain' do

      @t.filter :before do |prev, time, args, &block| 
        'nope'
      end
      @t.filter :before do |prev|
        prev.reverse
      end
      ('hello' + 'other').should == 'epon'
    end

    it "should filter after" do
      @t.filter :after do |prev, time, args, &block|
        prev + time
      end
      "hello" + "other" # => 'helloother0'
    end
  end
   
end