class Tivoli
  attr_accessor :method, :filters, :aspects
  
  def self.bench
    start = Time.now.to_f
    time_passed = proc {
      time_taken = ((Time.now.to_f - start)*1000).to_i
    }
    yield time_passed
    time_passed.call
  end

  def run(fallback, &block)
    key = :"tivoli_#{object_id}"
    return fallback.call if Thread.current[key]
    Thread.current[key] = true
    result = block.call
    Thread.current[key] = false
    result
  end
  
  def initialize(method)
    @method = method
    default_to_array = proc { |h,k| h[k] = [] }
    self.aspects = Hash.new(&default_to_array)
    self.filters = Hash.new(&default_to_array)

    tivoli = self
    
    method.owner.send(:define_method, method.name) do |*args, &blk|
      result = nil

      call_original_method = proc {
        method.bind(self)[*args, &blk]
      }

      tivoli.run(call_original_method) do
        time = Tivoli.bench do |time_passed|
          execute = proc { |state, &block|
            tivoli.aspects[state].each do |a|
              a.call(time_passed.call, args, &blk)
            end
            if tivoli.filters[state].empty?
              block.call
            else
              tivoli.filters[state].reduce(result) do |prev, f|
                f.call(prev, time_passed.call, args, &blk)
              end
            end
          }
          result = execute.call :before, &call_original_method
          result = execute.call :after do
            result
          end
        end
      end
      result
    end
  end

  def aspect(state, &block)
    aspects[state].push(block)
  end

  def filter(state, &block)
    filters[state].push(block)
  end

  def stop
    aspects.clear
    filters.clear
    method.owner.send(:define_method, method.name) do |*args, &blk|
      method.bind(self)[*args, &blk]
    end
  end
end