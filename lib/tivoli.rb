require 'bundler/setup'
class Tivoli
  attr_reader :method, :before_callbacks, :after_callbacks, :complete_callbacks
  
  def self.bench
    start = Time.now.to_f
    yield
    time_taken = ((Time.now.to_f - start)*1000).to_i
  end
  
  def initialize(method)
    @method = method
    @after_callbacks = []
    @before_callbacks = []
    @complete_callbacks = []
    tivoli = self
    
    method.owner.send(:define_method, method.name) do |*args|
      return method.bind(self)[*args] if Thread.current[:tivoli_callback]
      before_callbacks = tivoli.before_callbacks
      after_callbacks = tivoli.after_callbacks
      complete_callbacks = tivoli.complete_callbacks
      result = nil
      before_cancel = after_cancel = false
      time = Tivoli.bench {
        message , result = nil, nil
        before_time = Tivoli.bench {
          before_callbacks.each do |c|
            message, result = Tivoli.call_callback(c, *args)
          end
        }
        before_cancel = message == :change_result
        unless before_cancel
          call_time = Tivoli.bench {
            result = method.bind(self)[*args]
          }
        end
        after_result = nil
        after_cancel = false
        after_time = 0
        after_time = Tivoli.bench {
          after_callbacks.each do |c|
            after_callback_time = 0
            after_callback_time += Tivoli.bench {
              message, after_result = Tivoli.call_callback(c, 
                args, 
                after_cancel ? after_result : result,
                before_cancel || after_cancel,
                before_cancel ? before_time : call_time + after_callback_time)
            }
            after_cancel = message == :change_result
          end
        }
        result = after_result if after_cancel
      }
      complete_callbacks.each do |c|
        Tivoli.call_callback(c,args, result, before_cancel || after_cancel, time)
      end
      result
    end
  end
  
  def self.call_callback(c, *args)
    Thread.current[:tivoli_callback] = true
    c[*args]
  ensure
    Thread.current[:tivoli_callback] = false
  end
  
  def before(&block)
    @before_callbacks << block
  end
  
  def after(&block)
    @after_callbacks << block
  end
  
  def complete(&block)
    @complete_callbacks << block
  end
end