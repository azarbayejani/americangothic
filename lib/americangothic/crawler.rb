require('parallel')
require('open-uri')
require('raingrams')

include Raingrams

module AmericanGothic
	class Crawler

		attr_accessor :model

		def initialize opts

			if opts[:starturl] != nil
				@starturl = opts[:starturl]
			else
				@starturl = AmericanGothic::REVIEW_URL
			end

			if File.exists? "#{AmericanGothic::DATA_DIR}/model"
				@model = Model.open("#{AmericanGothic::DATA_DIR}/model")
			else
				@model = BigramModel.build :ngram_size => 5
			end

		end

		def crawl
			page = Nokogiri::HTML(open(@starturl))
			reviews = page.css('.object-grid a')

			should_i_continue = true

			loop do 
				# Parallel.each reviews, :in_threads=>8 do |a|

				reviews.each do |a|
					slug = a['href'].split("/")[-1]

					if File.exists? "#{DATA_DIR}/#{slug}"
						should_i_continue = false
						break
					else
						
						# TODO: is there a way to change this to be a block?
						currReview = Review.new_from_url "#{BASE_PITCHFORK_URL}#{a['href']}" unless File.exists? slug

						puts slug

						# TODO: when should 
						@model.train_with_text(currReview.text)

						File.open("#{DATA_DIR}/#{slug}",'w') do |f|
							f.write( currReview.to_json )
						end

					end

				end

				unless should_i_continue
					break
				end

				nextpage = page.css('.next:has(*)')

				if nextpage.empty?
					break
				else
					page = Nokogiri::HTML(open("#{BASE_PITCHFORK_URL}#{nextpage[0]['href']}"))
					reviews = page.css('.object-grid a')
				end
			end

			@model.refresh

			@model.save("#{AmericanGothic::DATA_DIR}/model")

		end

	end
end