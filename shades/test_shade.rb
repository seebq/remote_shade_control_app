# A dummy / test shade that simply echos commands to command line.
# 
class TestShade < Shade
  def up
    `echo "up"`
  end
  
  def stop
    `echo "stop"`
  end
  
  def down
    `echo "down"`
  end
end