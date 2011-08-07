

list = ObjectSpace.each_object.select do |o|
  o.class == Class || o.class == Module
end

methods = []
list.each do |c|
  methods += c.methods.map do |m|
    c.method(m)
  end
  methods += c.instance_methods.map do |m|
    c.instance_method(m)
  end
end

puts methods.count

require './lib/tivoli'

methods.each do |m|
  begin
    unless m.owner == Method
      t = Tivoli.new(m)
      t.complete { |*args|
        args.unshift m.name
        puts args.inspect
      }
    end
  rescue NoMethodError => e
    
  end
end