class CompositePersister
  attr_reader :persisters
  def initialize(*persisters)
    @persisters = persisters
  end

  # Not sure what to do here...
  def adapter
    persisters.first.adapter
  end

  def save(model)
    persisters.each do |persister|
      model = persister.save(model)
    end
    model
  end
end
