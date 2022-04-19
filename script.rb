require 'net/ftp'

ftp = Net::FTP.new('ftp.salsify.com')

puts "Enter FTP Server Username: "
username = gets.chomp()
puts "Enter FTP Server Password: "
password = gets.chomp()

ftp.login(username, password)