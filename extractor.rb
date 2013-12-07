require 'open-uri'
require 'nokogiri'
require 'nokogiri/diff'
require 'pry'

def runHtml(node, list)
  	p = node.parent;
  	path = p.path.gsub(/\[[0-9]+\]/, '')
	if list.has_key?(path)
		num = list.fetch(path)
		num += 1
		list[path] = num 
	else
		list[path] = 1
	end

	node.children().each do |children|
		runHtml(children, list)
	end
	#puts p.path
end

def maxOF(list, num)
	return  (list.to_a.values_at(*list.values.each_with_index
                         .sort.reverse
                         .map(&:last)
                         .sort.take(num))
         .map(&:first))
end

def getMostFreqPath(doc1)
	list = Hash.new 

	doc1.css('body a').children().each do | node |
	#if node.name() == 'div'
		runHtml(node, list)
	#end
	end

	l = list.sort_by{|key, val| val * -1}
	return l
end


def printPath(doc1, path)
	doc1.xpath(path).each do |node|
		p = node.parent()
		parent = p.parent()
		puts node.path
		puts node.name + ' ' + parent.to_html + "\n\n"
	end
end
#doc1 = Nokogiri::HTML(open('http://www.pontofrio.com.br/'))
doc1 = Nokogiri::HTML(open('http://www.magazineluiza.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.nytimes.com/'))
#doc1 = Nokogiri::HTML(open('http://www.gizmodo.com/'))



list = getMostFreqPath(doc1)

list.each do |key, val|
	doc1.xpath(key).each do |node|
		if node.element?
			puts key + ' é um elemento ' + node.children.length(). to_s
		else
			puts key + ' é um text'
		end
	end
	puts '' + key.to_s + ' ' + val.to_s 
end

first = list.first

path  = first.first

puts doc1.xpath(path).size

#printPath(doc1, path)