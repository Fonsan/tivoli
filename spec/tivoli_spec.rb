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
    @t.before &task
    @t.after &task
    @t.complete &task
    "aBc".upcase
    i.should == 3
  end
  
  describe 'manipulation' do
    it 'should be able to change result on before call' do
      bool = false
      Object.instance_eval do
        define_method :hello do
          !bool
        end
      end
      t = Tivoli.new Object.instance_method(:hello)
      o = Object.new
      bool = o.hello
      bool.should be_true
      bool = o.hello
      bool.should be_false
      t.before do
        [:change_result, false]
      end
      bool = o.hello
      bool.should be_false
    end
    
    it 'should be able to change result on after call' do
      bool = false
      Object.instance_eval do
        define_method :hello do
          !bool
        end
      end
      t = Tivoli.new Object.instance_method(:hello)
      o = Object.new
      bool = o.hello
      bool.should be_true
      bool = o.hello
      bool.should be_false
      t.after do
        [:change_result, false]
      end
      bool = o.hello
      bool.should be_false
    end
  end
  
end