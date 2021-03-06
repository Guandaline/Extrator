require 'open-uri'
require 'nokogiri'
require 'nokogiri/diff'
require 'pry'

def runHtml(node, list)
  	p = node.parent
  	path = p.path.gsub(/\[[0-9]+\]/, '')
  	#path = p.path
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
		puts parent.path
		puts node.to_html + ' ' + "\n\n"
	end
end

def extruct(doc1, path)
	doc1.xpath(path)[0..10].each do |node|
		puts node.path
		puts 'Numero de filhos de ' + node.name  + ' ' + node.children.length.to_s
		if  node.children.length > 1 
				node.children.each() do |child|
					puts child.name + ' [' + child.content.gsub("\n", '').gsub('	', '') + ']'
				end
			if typeChildrenHeterogeneos?(node)
				puts 'extraindo ... '
				
			else
				typeParent(node.parent)
			end
		else 
			if !node.child.element?()
				puts 'Não é um elemento = ' + node.child.content
				typeParent(node.parent)
			else 
				if typeChildrenHeterogeneos?(node.child)
					puts 'extraindo ...' + node.child.name
				else
				end
			end
		end
	end
end

def typeParent(node)
	if node.children == 1
		typeParent(node.parent)
	else 
		if typeChildrenHeterogeneos?(node)
			puts 'Extraindo : ' + node.name
			node.children.each do |c|
				puts c.name
			end
		else
			puts 'Menu em: ' + node.name
		end
	end

end

def typeChild(node)
	if node.children == 1
		typeParent(node.child)
	else 
		if typeChildrenHeterogeneos?(node)
			puts 'Extraindo : ' + node.name
		else
			puts 'Menu em: ' + node.name
		end
	end

end

def typeChildrenHeterogeneos?(node) 
	list = Hash.new 
	node.children.each do |child|
		key = child.name
		content = child.content.gsub("\n", '').gsub('	', '')
		if(!(content == '' && key != 'text'))
			if list.has_key?(key)
				num = list.fetch(key)
				num += 1
				list[key] = num 
			else
				list[key] = 1
			end
		end
	end
	
	if list.size > 1
		return true
	end
	return false
end



doc1 = Nokogiri::HTML(open('http://www.pontofrio.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.magazineluiza.com.br/'))
#doc1 = Nokogiri::HTML(open('http://www.nytimes.com/'))
#doc1 = Nokogiri::HTML(open('http://www.gizmodo.com/'))



list = getMostFreqPath(doc1)

list[0..5].each do |key, val|
	#doc1.xpath(key).each do |node|
#		if node.element?
#			puts key + ' é um elemento ' + node.children.length(). to_s
#		else
#			puts key + ' é um text'
#		end
#	end
#	puts '' + key.to_s + ' ' + val.to_s 
	extruct(doc1, key);
end

#first = list.first
#path  = first.first

#puts doc1.xpath(path).size

#printPath(doc1, '/html/body/div/div/div/div/div/a')
#extruct(doc1, path)