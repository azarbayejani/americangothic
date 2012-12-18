require('../lib/american_gothic.rb')

#TODO: move this to bin/americangothic.rb

opts = Trollop::options do
	version "americangothic 0.0.0 (c) 2012 Bobby Azarbayejani"
	banner <<-EOS
americangothic takes pitchfork reviews does something clever with them.

Usage: 
			americangothic [options] <integer>

where <integer> is the n-gram to be generated

EOS
	opt :rebuild, 
		<<-EOS
Do a full rebuild from online (deleting cache)
		EOS
end

crawler = new AmericanGothic::Crawler
crawler.crawl