class C
  def self.x
    puts "x of C"
  end

  def y
    self.class.x
  end

  def z
    C.x
  end
end

class D < C
  def self.x
    puts "x of D"
  end
end

puts "Calling y on an instance of C"
C.new.y

puts "Calling y on an instance of D"
D.new.y

puts "Calling z on an instance of D"
D.new.z