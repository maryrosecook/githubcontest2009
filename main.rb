require 'in_out'
require 'util'

# get test user, find followed repos, find followers of those repos,
# find all their followed repos, create ranked list of most popular,
# repeat for each test user, write to file
def self.calculate_and_write_collab_file(test, data, repo_followers)
  collab = {}
  
  counter = 0
  for test_user_id in test # run through repos followed by test user
    collab[test_user_id] = {}
    
    potential_repos = {}
    if data.has_key?(test_user_id)
      # get all repos followed by followers of this repo
      for followed_repo_id in data[test_user_id]
        for follower_id in repo_followers[followed_repo_id]
          if follower_id != test_user_id
            for potential_repo_id in data[follower_id]
              if !potential_repos.has_key?(potential_repo_id)
                potential_repos[potential_repo_id] = 1
              else
                potential_repos[potential_repo_id] += 1
              end
            end
          end
        end
      end

      # rank by repo score and put into user_repos hash
      potential_repo_ids = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }
      i = 0
      for i in (0..Util.min(2000, potential_repo_ids.length))
        if potential_repo_id = potential_repo_ids[i]
          collab[test_user_id][potential_repo_id] = potential_repos[potential_repo_id]
        end
      end
    end

    print counter.to_s + "\n"
    counter += 1
  end

  print "\nwootwootwoot\n"
  
  InOut.write_collab(collab)
end

def self.calculate_user_lang(lang, test, data)
  user_lang = {}
  for test_user_id in test # run through repos followed by test user
    user_lang[test_user_id] = {}
    
    if data.has_key?(test_user_id)
      for followed_repo_id in data[test_user_id]
        if lang.has_key?(followed_repo_id)
          for lang_name in lang[followed_repo_id].keys
            user_lang[test_user_id][lang_name] = 0 if !user_lang[test_user_id].has_key?(lang_name)
            user_lang[test_user_id][lang_name] += lang[followed_repo_id][lang_name]
          end
        end
      end
    end
  end
  
  return user_lang
end

def self.calculate_top_user_lang(user_lang)
  top_user_lang = {}
  for user_id in user_lang.keys
    top_user_lang[user_id] = {}
    i = 0
    for lang_name in user_lang[user_id].keys.sort { |x,y| user_lang[user_id][y] <=> user_lang[user_id][x] }
      top_user_lang[user_id][lang_name] = user_lang[user_id][lang_name]
      break if i > 2
      i += 1
    end
  end
  
  return top_user_lang
end

# get most followed repos
def self.calculate_most_popular_repos(repo_followers)
  i = 0
  most_popular_repos = []
  for repo_id in repo_followers.keys.sort { |x,y| repo_followers[y].length <=> repo_followers[x].length }
    most_popular_repos << repo_id
    break if i > 9
    i += 1
  end
  
  return most_popular_repos
end

##########

print "reading data\n"
data = InOut.read_data()
lang = InOut.read_lang()
test = InOut.read_test()
user_lang = calculate_user_lang(lang, test, data)
top_user_lang = calculate_top_user_lang(user_lang)
repo_followers = Util.rotate_hash(data)
most_popular_repos = calculate_most_popular_repos(repo_followers)
calculate_and_write_collab_file(test, data, repo_followers) if !File.exist?(InOut::COLLAB_FILE_PATH) # only run if file not there
collab = InOut.read_collab()
print "calculating\n"

# get results
results = {}
counter = 0
for test_user_id in test
  results[test_user_id] = []
  if collab.has_key?(test_user_id)
    potential_repos = collab[test_user_id]
    ranked_potential_repos = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }
    if ranked_potential_repos.length > 0
      (0..Util.min(9, ranked_potential_repos.length)).each { |i| results[test_user_id] << ranked_potential_repos[i] }
    end
  end
  
  print counter.to_s + "\n"
  counter += 1
end

# suggest most popular repos to users w/o suggestions
results.keys.each { |user_id| results[user_id] = most_popular_repos if results[user_id].length == 0 }

InOut.output_results(results)