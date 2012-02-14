class Pool
  attr_reader :size

  def initialize(size = 10)
    @size, @resources = size, EM::Queue.new
    size.times { @resources.push(yield) }
  end

  def execute
    @resources.pop do |resource|
      yield(resource).tap do |deferable|
        deferable.callback { @resources.push(resource) }
        deferable.errback  { @resources.push(resource) }
      end
    end
  end
end
