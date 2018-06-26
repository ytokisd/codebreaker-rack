# comment
class DataManager
  def write_results(attempts, hint)
    username = gets.chomp
    results = './lib/results.yml'
    File.open(results, 'a') { |file| file.write("#{username} finished game with #{attempts -1} attempts left. Hint is unused? : #{hint} \n") }
  end

  def view_results
    puts  File.read('./lib/results.yml')#, 'r')# do |file|
#      file.each_line do |line|
#        puts line
#      end
#    end
  end
end