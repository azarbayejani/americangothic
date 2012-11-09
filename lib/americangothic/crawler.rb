require('parallel')
require('nokogiri')
require('open-uri')

class Crawler

	def initialize starturl

		if starturl != nil
			@starturl = starturl
		else
			@starturl = AmericanGothic::REVIEW_URL
		end

		if File.exists? "#{AmericanGothic::DATA_DIR}/model"
			@model = model.open("#{AmericanGothic}/model")
		else
			@model = model.build :ngram_size => 3
		end

	end

	def crawl
		page = Nokogiri::HTML(open(starturl))

		loop do 
			Parallel.each reviews, :in_threads=>8 do |a|
				currReview = Review.new_from_url "#{BASE_PITCHFORK_URL}#{a['href']}" unless File.exists? a['href']
				puts a['href']
				model.train_with_text(currReview.text)
			end

			nextpage = page.css('.next:has(*)')

			if nextpage.empty?
				break
			else
				page = Nokogiri::HTML(open("#{BASE_PITCHFORK_URL}#{nextpage[0]['href']}"))
				reviews = page.css('.object-grid a')
			end
		end

	end

end