$hook

class Reset
  def self.run
    [:Example, :Number, :Add, :Multiply, :Boolean, :LessThan, :GreaterThan, :Variable,
     :Assign, :If, :Sequence, :DoNothing, :While
    ].each do |klass_name|
      klass = Module.const_get(klass_name)
      Object.send(:remove_const, klass_name) if klass.is_a?(Class)
    end
    load "./large_step_semantics.rb"
    Example.run
  end
end

class Example
  def self.run
    $hook = Boolean.new(false).to_ruby
  end
end

Number = Struct.new(:value) do
  def evaluate(environment)
    self
  end

  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

Boolean = Struct.new(:value) do
  def evaluate(environment)
    self
  end

  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

Variable = Struct.new(:name) do
  def evaluate(environment)
    environment[name]
  end

  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end
end

Add = Struct.new(:left, :right) do
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

Multiply = Struct.new(:left, :right) do
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end
end

LessThan = Struct.new(:left, :right) do
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end
end

GreaterThan = Struct.new(:left, :right) do
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value > right.evaluate(environment).value)
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) > (#{right.to_ruby}).call(e) }"
  end
end

Assign = Struct.new(:name, :expression) do
  def evaluate(environment)
    environment.merge({ name => expression.evaluate(environment) })
  end

  def to_ruby
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end
end

class DoNothing
  def evaluate(environment)
    environment
  end

  def to_ruby
    "-> e { e }"
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

  def to_ruby
    "-> e { if (#{condition.to_ruby}).call(e)" +
    " then (#{consequence.to_ruby}).call(e)" +
    " else (#{alternative.to_ruby}).call(e)" +
    " end }"
  end
end

Sequence = Struct.new(:first, :second) do
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end

  def to_ruby
    "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
  end
end

While = Struct.new(:condition, :body) do
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end

  def to_ruby
    "-> e {" +
      " while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
      " e" +
      " }"
  end
end
