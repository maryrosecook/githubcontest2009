require 'util'

class InOut

  DATA_FILE_PATH = "download/data.txt"
  LANG_FILE_PATH = "download/lang.txt"
  REPOS_FILE_PATH = "download/repos.txt"
  TEST_FILE_PATH = "download/test.txt"
  RESULTS_FILE_PATH = "results.txt"
  COLLAB_FILE_PATH = "collab.txt"

  def self.write_collab(collab)
    File.delete(COLLAB_FILE_PATH) if File.exist?(COLLAB_FILE_PATH)
    f = File.open(COLLAB_FILE_PATH, 'a')
    
    counter = 0
    for user_id in collab.keys#.sort { |x,y| x <=> y }
      f.write(user_id.to_s + ":")
      i = 0
      for repo_id in collab[user_id].keys.sort { |x,y| collab[user_id][y] <=> collab[user_id][x] }
        f.write(",") if i > 0
        f.write(repo_id.to_s + ";" + collab[user_id][repo_id].to_s)
        i += 1
      end
      
      f.write("\n")
      
      print counter.to_s + "\n"
      counter += 1
    end
  end

  def self.read_collab
    collab = {}
    File.open(COLLAB_FILE_PATH, "r") do |f|
      while !f.eof?
        line = f.readline
        
        user_id = line.gsub(/([^:]*).*/, '\1').strip.to_i
        collab[user_id] = {}
        repos_str = line.gsub(/[^:]*:/, "").strip
        for repo_str in repos_str.split(",")
          repo = repo_str.split(";")
          collab[user_id][repo[0].to_i] = repo[1].to_i
        end
      end
    end
    
    return collab
  end
  
  def self.read_lang
    lang = {}
    File.open(LANG_FILE_PATH, "r") do |f|
      while !f.eof?
        line = f.readline
        
        repo_id = line.gsub(/([^:]*).*/, '\1').strip.to_i
        lang[repo_id] = {}
        langs_str = line.gsub(/[^:]*:/, "").strip
        for lang_str in langs_str.split(",")
          lang_arr = lang_str.split(";")
          lang[repo_id][lang_arr[0]] = lang_arr[1].to_i
        end
      end
    end
    
    return lang
  end
  
  def self.read_data
    data = {}
    File.open(DATA_FILE_PATH, "r") do |f|
      while !f.eof?
        line_els = f.readline.split(":")
        user_id = line_els[0].strip.to_i
        repo_id = line_els[1].gsub(/\n/, "").to_i
        if Util.ne(user_id) && Util.ne(repo_id)
          data[user_id] = [] if !data.has_key?(user_id)
          data[user_id] << repo_id
        end
      end
    end

    return data
  end

  def self.read_repos
    repos = []
    File.open(REPOS_FILE_PATH, "r") do |f|
      while !f.eof?
        line = f.readline
        repo = {}
        repo[:repo_id] = line.gsub(/([^:]*).*/, '\1').strip.to_i
        repo[:repo_url] = line.gsub(/[^:]*:([^,]*).*/, '\1').strip
        repo[:created_at] = line.gsub(/[^:]*:[^,]*,(.*)/, '\1').strip
        fork_repo_id = line.gsub(/[^:]*:[^,]*,[^,]*,(.*)/, '\1').strip.to_i
        fork_repo_id.match(/,/) ? repo[:fork_repo_id] = nil : repo[:fork_repo_id] = fork_repo_id
        repos << repo
      end
    end

    return repos
  end

  def self.read_test
    test = []
    File.open(TEST_FILE_PATH, "r") do |f|
      while !f.eof?
        test << f.readline.gsub(/\n/, "").to_i
      end
    end

    return test
  end

  def self.output_results(users_repos)
    File.delete(RESULTS_FILE_PATH) if File.exist?(RESULTS_FILE_PATH)
    f = File.open(RESULTS_FILE_PATH, 'a')
        
    for user_id in users_repos.keys.sort { |x,y| x <=> y }
      f.write(user_id.to_s + ":")
      i = 0
      for repo_id in users_repos[user_id]
        if repo_id
          f.write(",") if i > 0
          f.write(repo_id)
          i += 1
        end
      end
      
      f.write("\n")
    end
  end
end