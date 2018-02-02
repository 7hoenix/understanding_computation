class Reset
  def self.run
    [:Example, :Number, :Add, :Multiply, :Boolean, :LessThan, :GreaterThan, :Variable,
     :Assign, :If, :Sequence, :DoNothing
    ].each do |klass|
      Object.send(:remove_const, klass)
    end
    load "./large_step_semantics.rb"
    Example.run
  end
end

class Example
  def self.run
    Sequence.new(
      Assign.new(:x, Add.new(Number.new(3), Number.new(1))),
      Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))),
    ).evaluate({})
  end
end

Number = Struct.new(:value) do
  def evaluate(environment)
    self
  end
end

Boolean = Struct.new(:value) do
  def evaluate(environment)
    self
  end
end

Variable = Struct.new(:name) do
  def evaluate(environment)
    environment[name]
  end
end

Add = Struct.new(:left, :right) do
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

Multiply = Struct.new(:left, :right) do
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

LessThan = Struct.new(:left, :right) do
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end

GreaterThan = Struct.new(:left, :right) do
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value > right.evaluate(environment).value)
  end
end

Assign = Struct.new(:name, :expression) do
  def evaluate(environment)
    environment.merge({ name => expression.evaluate(environment) })
  end
end

class DoNothing
  def evaluate(environment)
    environment
  end
end

If = Struct.new(:condition, :consequence, :alternative) do
  def evalatue(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end
end

Sequence = Struct.new(:first, :second) do
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end
