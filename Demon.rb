# This class represents demons.
class Demon
  
  def initialize(name, race, level)
    # The demon's name
    @name = name
    # The demon's race
    @race = race
    # The demon's base level. This differs from current level and is what's
    # used in calculations for fusions for consistency.
    @level = level
  end
  
  # Accessor for @name
  def get_name
    return @name
  end

  # Accessor for @race  
  def get_race
    return @race
  end
  
  # Accessor for @level
  def get_level
    return @level
  end
  
  # Overloading equals method.
  def ==(another_demon)
    @name == another_demon.get_name &&
    @race == another_demon.get_race &&
    @level == another_demon.get_level
  end
end