require './Demon'

# Global variables for element strings.
$Element = "Element"
$Erthys = "Erthys"
$Aquans = "Aquans"
$Aeros = "Aeros"
$Flaemis = "Flaemis"

# This handles demon fusions: it's cath.exe, if you will.
class Fusion
  # This is in the format {Race1 => {Race2 => Race3, ...}, ...} where
  # Race1 and Race2 combine to make Race3, so you could search
  # @@combo_hash["Tyrant"]["Kishin"] to get the result "Fallen". This also
  # works in reverse, so @@combo_hash["Kishin"]["Tyrant"] also gets "Fallen". 
  @@combo_hash = {}
    
  # This is in the format {Race => {Level => Demon, ...}, ...} so that you can
  # search by race, then determine the level of a resulting demon by picking
  # the level closest to an average level.
  @@demon_hash = {}
    
  # A hash that stores elements; that is, fusing two demons of the same race
  # results in an element, so this looks up what race would result in what
  # element.
  @@element_hash = {}
  
  # Read from the given file to populate @@combo_hash. The file should be
  # formatted so each line follows the pattern "race1,race2,race3" where
  # race1 and race2 combine to make race3. Note that duplicate combo lines,
  # i.e. "race2,race1,race3" do not need to be included. 
  def init_combo_hash(filename)
    
    # Initialize an array to hold each line as an array to add to the hash.
    data = Array.new
    
    # Open filename and process.
    fileObj = File.open(filename, "r") do |f|
      f.each_line do |line|
        
        # Remove any trailing whitespace characters and store the line as
        # an array.
        data = line.strip.split(",")
        
        # Now add each array to the combo hash and do it for 0x1=2 and 1x0=2
        add_to_combo_hash(data[0], data[1], data[2])
        add_to_combo_hash(data[1], data[0], data[2])
      end
    end
  end

  # Add the given combination to @@combo_hash. race1 is the first key, which
  # points to all of the other races, which themselves are also hashes with
  # race2 as a key. The final level of @@combo_hash is the resulting race
  # of a fusion between race1 and race2.  
  def add_to_combo_hash(race1, race2, race3)
    if @@combo_hash.key?(race1)
      if @@combo_hash
        @@combo_hash[race1][race2] = race3
      else
        @@combo_hash[race1] = { race2 => race3 }
      end
    else
      @@combo_hash[race1] = { race2 => race3}
    end
  end
  
  # Read from the given file to populate @@demon_hash. The file should be
  # formatted so each line follows the pattern "race,level,name".
  def init_demon_hash(filename)
    data = Array.new
    
    fileObj = File.open(filename, "r") do |f|
      f.each_line do |line|
        data = line.strip.split(",")
        add_to_demon_hash(data[0], data[1].to_i, data[2])
      end
    end
  end
  
  # Add the given demon to @@demon_hash
  def add_to_demon_hash(race, level, name)
    if @@demon_hash.key?(race)
      @@demon_hash[race][level] = name
    else
      @@demon_hash[race] = {level => name}
    end
  end
  
  # Read from the given file to populate @@element_hash. The file should be
  # formatted so each line follows the pattern "race, element_name".
  def init_element_hash(filename)
    data = Array.new
    
    fileObj = File.open(filename, "r") do |f|
      f.each_line do |line|
        data = line.strip.split(",")
        add_to_element_hash(data[0], data[1])
      end
    end
  end
    
  # Add the given race to the element hash.
  def add_to_element_hash(race, element)
    @@element_hash[race] = element
  end
  
  # Combine demon1 and demon2 and return the resulting fusion.
  def fuse(demon1, demon2)
    
    # Store the races of both demons locally for easier access.
    race1 = demon1.get_race
    race2 = demon2.get_race
    
    # If the two races are the same, then we're fusing an Element.
    if race1 == race2
      
      # Unless we're fusing two elements, in which case we get a Mitama
      if race1 == $Element
        puts "MITAMA"
      end
      
      element = @@element_hash[race1]
      if element == $Erthys
        return make_element($Erthys, 7)
      elsif element == $Aeros
        return make_element($Aeros, 12)
      elsif element == $Aquans
        return make_element($Aquans, 17)
      elsif element == $Flaemis
        return make_element($Flaemis, 22)
      end
    
    # If we're fusing an Element with something else, then that means
    # we're moving up or down the species of the other race.
    elsif (race1 == $Element) ^ (race2 == $Element)
      puts "1234"
    
    # Otherwise, try an actual fusion.
    else 
      
      # Let's check for special fusions first!
      sp_result = special_fusion(demon1, demon2)
      
      if sp_result
        return sp_result
      end
      
      # Store the base levels of both demons...
      level1 = demon1.get_level
      level2 = demon2.get_level
      
      # Find the average level + 1 and the resulting race.
      avglevel = ((level1 + level2) / 2) + 1
      result_race = @@combo_hash[race1][race2]
      
      # Pick the demon of the resulting race whose level the next highest in
      # the poss_levels list
      race_list = @@demon_hash[result_race]
      poss_levels = race_list.keys
      actual_level = poss_levels.sort.min_by{|x|(avglevel-x).abs}
      name = race_list[actual_level]
      return make_demon(name, result_race, actual_level)
    end
  end

  # Some specific demon combos result in a specific result, so we're
  # checking that here
  def special_fusion(demon1, demon2)
    
    if compare_for_special(demon1, demon2, "Ogun", "Jack Frost")
      return make_demon("Ghost Q", "Fiend", 26)
      
    elsif compare_for_special(demon1, demon2, "Nekomata", "Thor")
      return make_demon("Neko Shogun", "Hero", 31)
      
    elsif compare_for_special(demon1, demon2, "Berserker", "Ictinike")
      return make_demon("Hagen", "Hero", 39)
      
    elsif compare_for_special(demon1, demon2, "Odin", "Orthrus")
      return make_demon("Sage of Time", "Fiend", 41)
      
    elsif compare_for_special(demon1, demon2, "Mothman", "Silky")
      return make_demon("Billiken", "Fiend", 50)
      
    elsif compare_for_special(demon1, demon2, "Hecate", "Scathach")
      return make_demon("Jeanne D'Arc", "Hero", 50)
      
    elsif compare_for_special(demon1, demon2, "Osiris", "Take-Mikazuchi")
      return make_demon("Yoshitsune", "Hero", 57)
      
    elsif compare_for_special(demon1, demon2, "Tzitzimitl", "Remiel")
      return make_demon("Trumpeter", "Fiend", 63)
      
    elsif compare_for_special(demon1, demon2, "Nata Taishi", "Murmur")
      return make_demon("Guan Yu", "Hero", 70)
      
    elsif compare_for_special(demon1, demon2, "Rangda", "Barong")
      return make_demon("Shiva", "Omega", 76)
      
    elsif compare_for_special(demon1, demon2, "Amaterasu", "Yoshitsune")
      return make_demon("Masakado", "Hero", 82)
  
    elsif compare_for_special(demon1, demon2, "Belial", "Nebiros")
      return make_demon("Alice", "Fiend", 88)
      
    elsif compare_for_special(demon1, demon2, "Metatron", "Loki")
      return make_demon("Lucifer", "Tyrant", 99)
    
    else
      return nil
    end
  end
  
  # Helper function for fuse that determines the level of the result demon
  def get_result_level(level_array, avg_level)
    
    # If the result level exceeds the maximum level of the given array,
    # then just return the maximum level.
    if avg_level > level_array.max
      return level_array.max
      
    # Otherwise, just return the next highest level from avg_level
    else
      
      # Sort the array by the absolute value distance from avg_level
      sorted_range = level_array.sort_by{|x|(avg_level-x).abs}
      
      # Initialize the result and an iterator
      result = 0
      i = 0
      
      # While result is less than avg_level, overwrite result until we find
      # a value that's greater than avg_level.
      while result < avg_level
        result = sorted_range[i]
        i = i + 1
      end
      
      # Return result
      return result
    end
  end
  
  # Helper function for the above.
  def compare_for_special(demon1, demon2, name1, name2)
    return (demon1.get_name == name1 && demon2.get_name == name2) |
           (demon1.get_name == name2 && demon2.get_name == name1)
  end
  
  # Make a demon
  def make_demon(name, race, level)
    return Demon.new(name, race, level)
  end
  
  # Make an Element demon.
  def make_element(name, level)
    return make_demon(name, $Element, level)
  end
    
  # Accessor for @@combo_hash
  def get_combo_hash
    return @@combo_hash
  end
  
  # Accessor for @@element_hash
  def get_element_hash
    return @@element_hash
  end

  # Accessor for @@demon_hash
  def get_demon_hash
    return @@demon_hash
  end

end