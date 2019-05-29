require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper 
	url = "https://www.indeed.com/jobs?q=software+engineer&l=Middletown%2C+DE"
	unparsed_page = HTTParty.get(url)
	parsed_page = Nokogiri::HTML(unparsed_page)

	jobs = Array.new
	job_listings = parsed_page.css("div.jobsearch-SerpJobCard")

	page = 1
	per_page = job_listings.count
	total = parsed_page.css('div#searchCount').text.split(' ')[3].gsub(',','').to_i
	last_page = (total.to_f / per_page.to_f).round

	while page <= last_page
		#this site increases query parameter by 10 and starts at 0 for page 1
		#&start=0 -> url for page 1
		#&start=20 -> url for page 3
		current_page = page * 10 - 10
		pagination_url = "https://www.indeed.com/jobs?q=software+engineer&l=Middletown%2C+DE&start=#{current_page}"
		# puts pagination_url
		# puts "Page: #{page}"
		# puts ""
		pagination_unparsed_page = HTTParty.get(pagination_url)
		pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
		pagination_job_listings = pagination_parsed_page.css("div.jobsearch-SerpJobCard")
		pagination_job_listings.each do |job_listing|
			job = {
				title: job_listing.css('a.jobtitle').text,
				company: job_listing.css('span.company').text,
				location: job_listing.css('div.location').text,
				url: "https://www.indeed.com" + job_listing.css('a.jobtitle')[0].attributes["href"].value
			}
			jobs << job
			# puts "Added #{job[:title]}"
			# puts ""
		end
		page += 1
	end

	# byebug
end 

scraper