require 'open-uri'
require 'nokogiri'
require 'nokogiri/diff'
require 'pry'

def runHtml(node, list)
  	p = node.parent
  	path = p.path.gsub(/\[[0-9]+\]/, '')
  
	if list.has_key?(path)
		num = list.fetch(path)
		num += 1
		list[path] = num 
	else
		list[path] = 1
	end

	node.children().each do |child|
		runHtml(child, list)
	end
	
end


def getMostFreqPath(doc1)
	list = Hash.new 

	doc1.css('body a').children().each do | node |
		#puts node.parent.path
		runHtml(node, list)
	end
	l = list.sort_by{|key, val| val * -1}
	return l
end


def checkStruct(doc1, path)
	total_elements = doc1.xpath(path).length
	puts total_elements.to_s 
	puts path
	doc1.xpath(path)[0..0].each do |node|
		if node.name == 'a'
			num_total = countIn(node)
			num_children = countValidNode(node)
			#puts 'Link encontrado ' 
			#puts 'Filhos de a: ' + num_children.to_s
			#puts 'Total de elementos em a: ' + num_total.to_s
			if (num_total == 1 && num_children == 1)
				checkOut(node.parent.parent, node.parent.name + ' > a' , total_elements,1)
			else
				puts 'fuck the police'
			end
		else
			checkStruct(doc1, node.parent.path)
		end
	end
end

def checkOut(node, select, total, nivel)

	links = node.css(select).length 

	if links > 2
		l_parente =  node.parent.css(node.name + ' ' + select).length
		puts node.name + ' tem ' + l_parente.to_s  +  ' links'
		if l_parente > links  
			if l_parente <= total
				checkOut(node.parent, node.name + ' ' + select, total, nivel + 1)
			else
				puts node.path
				#puts node.to_html.gsub("\n", '').gsub('  ', '')
			end
		else
			puts node.path
			#puts node.to_html.gsub("\n", '').gsub('  ', '')
		end
	else
		if nivel < 10
			puts node.name + ' ' + select + ' ' + links.to_s
			#puts node.to_html
			checkOut(node.parent, node.name + ' > ' + select, total, nivel + 1)			
		end
	end

end

def isMenu(node)
	elementos = countValidNode(node)

end

def checkVizinhos(node)
	name = node.name
	parent = node.parent
	count = 0;
	parent.children.each do |no|
		if (no.name == name)
			count += 1
		end
	end 
	return count
end

def countIn(node)
	count = countValidNode(node)
	node.children.each do |child|
		count += countIn(child)
	end
	return count
end

def countValidNode(node)
	count = 0;
	node.children.each do |n|
		content = n.content.gsub("\n", '').gsub('	', '').gsub(' ', '')
		if (!(content == '' && n.name != 'text') && n.name != 'script' && n.name != 'noscript')
			count += 1
		end
	end
	return count
end

#doc1 = Nokogiri::HTML(open('http://www.pontofrio.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.magazineluiza.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.nytimes.com/'))
#doc1 = Nokogiri::HTML(open('http://www.gizmodo.com/'))
#doc1 = Nokogiri::HTML(open('http://www.kotaku.com/'))
doc1 = Nokogiri::HTML(open('http://g1.globo.com/'))
#doc1 = Nokogiri::HTML(open('http://www.skoob.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.youtube.com'))

list = getMostFreqPath(doc1)

list[0..5].each do |key, val|
	checkStruct(doc1, key);
end

