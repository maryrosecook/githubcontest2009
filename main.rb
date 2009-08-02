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

##########

print "reading data\n"

data = InOut.read_data()
lang = InOut.read_lang()
test = InOut.read_test()

user_lang = calculate_user_lang(lang, test, data)
top_user_lang = calculate_top_user_lang(user_lang)
repo_followers = Util.rotate_hash(data)
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

    # remove repos that don't feature a lang the user likes
    # for potential_repo_id in potential_repos.keys
    #   user_likes_lang = false
    #   if lang.has_key?(potential_repo_id)
    #     for repo_lang_name in lang[potential_repo_id].keys
    #       if top_user_lang.has_key?(test_user_id)
    #         for user_lang_name in top_user_lang[test_user_id]
    #           user_likes_lang = true if repo_lang_name == user_lang_name
    #         end
    #       else
    #         user_likes_lang = true
    #       end
    #     end
    #   else
    #     user_likes_lang = true
    #   end
    # 
    #   potential_repos.delete(potential_repo_id) if !user_likes_lang
    # end

    #print potential_repos.keys.length.to_s + "\n"

    # rank by repo score
    ranked_potential_repos = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }

    # recommend top ten
    (0..Util.min(9, ranked_potential_repos.length)).each { |i| results[test_user_id] << ranked_potential_repos[i] }
  end
  
  #print counter.to_s + "\n"
  counter += 1
end

InOut.output_results(results)