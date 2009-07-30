class Util
  
  def self.max(a,b)
    max = nil
    b > a ? max = b : max = a
    return max
  end

  def self.ne(str)
    str && str != ""
  end

  def self.rotate_hash(hash)
    rotated_hash = {}
    for key in hash.keys()
      for item in hash[key]
        if rotated_hash.has_key?(item)
          rotated_hash[item] << key
        else
          rotated_hash[item] = [key]
        end
      end
    end

    rotated_hash
  end
  
end