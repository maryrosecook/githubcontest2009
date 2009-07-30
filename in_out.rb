require 'util'

class InOut

  DATA_FILE_PATH = "download/data.txt"
  LANG_FILE_PATH = "download/lang.txt"
  REPOS_FILE_PATH = "download/repos.txt"
  TEST_FILE_PATH = "download/test.txt"
  
  def self.read_data
    data = {}
    File.open(DATA_FILE_PATH, "r") do |f|
      while !f.eof?
        line_els = f.readline.split(":")
        user_id = line_els[0].strip
        repo_id = line_els[1].gsub(/\n/, "")
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
        repo[:repo_id] = line.gsub(/([^:]*).*/, '\1').strip
        repo[:repo_url] = line.gsub(/[^:]*:([^,]*).*/, '\1').strip
        repo[:created_at] = line.gsub(/[^:]*:[^,]*,(.*)/, '\1').strip
        fork_repo_id = line.gsub(/[^:]*:[^,]*,[^,]*,(.*)/, '\1').strip
        fork_repo_id.match(/,/) ? repo[:fork_repo_id] = "" : repo[:fork_repo_id] = fork_repo_id
        repos << repo
      end
    end

    return repos
  end

  def self.read_test
    test = []
    File.open(TEST_FILE_PATH, "r") do |f|
      while !f.eof?
        test << f.readline.gsub(/\n/, "")
      end
    end

    return test
  end

  def self.output_results(users_repos)
    out = ""
    counter = 0
    for user_id in users_repos.keys
      out += user_id + ":"
      i = 0
      for repo_id in users_repos[user_id]
        if repo_id
          out += "," if i > 0
          out += repo_id
          i += 1
        end
      end
      
      out += "\n"
      print counter.to_s + "\n"
      counter += 1
    end
    
    File.open("results.txt", 'w') {|f| f.write(out) }
  end
end