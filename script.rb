require 'net/ftp'
require 'http'
require 'json'
require 'crack'

begin
  # empty string variable to be set after reading products.xml
  xml_data = ''
  ftp = Net::FTP.new('ftp.salsify.com')

  # ask for username
  puts "Enter FTP Server Username: "
  username = gets.chomp()
  # ask for password
  puts "Enter FTP Server Password: "
  password = gets.chomp()
  # ask for auth token
  puts "Enter your Bearer Token: "
  bearer_token = gets.chomp()

  # user login
  ftp.login(username, password)
  ftp.list('n*')
  # retrieve remote products.xml file and save it to a local products-data.xml
  ftp.getbinaryfile('products.xml', 'products-data.xml', 1024)
  puts "Great! Data from the remote version of products is now reflected in your local products-data file!"

  # open and read xml file
  # update xml_data variable with the read data
  File.open('products-data.xml', 'r') do |file|
    xml_data = file.read
  end

  # implement crack gem to parse xml data
  parsed_xml = Crack::XML.parse(xml_data)
  # take parsed xml data and convert to json
  json_data = parsed_xml.to_json

  # open a new products-data file and write 'json_data' to it
  File.open('products-data.json', 'w') do |file|
    file.write(json_data)
    puts "XML data has also successfully been converted to json! It is available in the products-data.json file!"
  end
  # parse the json data
  parsed_json = JSON.parse(json_data)

  # access product data, iterate over the records, set product_id for each product, and format request with auth headers, request method, and body
  parsed_json["products"]["product"].each do |product|
    product_id = product["SKU"]
    auth_token = "Bearer " + bearer_token.to_s

    response = HTTP.headers(:Authorization => auth_token).put("https://app.salsify.com/api/v1/products/#{product_id}", :json => product)

    puts "Successful update of product id: #{product_id}." if response.status == 200 || 204
  end
rescue StandardError => e
  puts e.message
ensure
  # close ftp connection
  puts "All done. FTP connection closing."
  ftp.close
end