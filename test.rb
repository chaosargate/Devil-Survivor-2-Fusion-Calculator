#!/usr/bin/ruby -w
require './Demon'
require "./Fusion"

lucifer = Demon.new("Lucifer", "Tyrant", 99);
okuninushi = Demon.new("Okuninushi", "Kishin", 87);
purple_mirror = Demon.new("Purple Mirror", "Ghost", 61);
rangda = Demon.new("Rangda", "Femme", 58);
barong = Demon.new("Barong", "Avatar", 68);
shiva = Demon.new("Shiva", "Omega", 76);
nebiros = Demon.new("Nebiros", "Fallen", 86);
belial = Demon.new("Belial", "Tyrant", 86);

fu = Fusion.new();
fu.init_combo_hash("fusion_chart_desu2.txt")
fu.init_demon_hash("desu2_demons.txt")
fu.init_element_hash("element_fusion.txt")

#puts demons["Kishin"].keys

e1 = fu.fuse(lucifer, okuninushi)
puts e1.get_name

e2 = fu.fuse(lucifer, purple_mirror)
puts e2.get_name()

e3 = fu.fuse(okuninushi, purple_mirror)
puts e3.get_name()

puts e1 == fu.fuse(okuninushi, lucifer)

puts fu.fuse(rangda,barong) == fu.fuse(barong, rangda)
puts fu.fuse(rangda, barong) == shiva
puts fu.special_fusion(rangda, barong) == shiva
puts fu.fuse(shiva,barong).get_name
puts fu.fuse(nebiros, belial).get_name