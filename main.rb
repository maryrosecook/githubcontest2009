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
              potential_repos[potential_repo_id] = 0 if !potential_repos.has_key?(potential_repo_id)
              potential_repos[potential_repo_id] += 1
            end
          end
        end
      end

      # rank by repo score and put into user_repos hash
      potential_repo_ids = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }
      for i in (0..Util.min(500, potential_repo_ids.length))
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

##########

data = InOut.read_data()
repo_followers = Util.rotate_hash(data)
#repos = read_repos()
test = InOut.read_test()
calculate_and_write_collab_file(test, data, repo_followers) if !File.exist?(InOut::COLLAB_FILE_PATH) # only run if file not there
collab = InOut.read_collab()

# get results
results = {}
for test_user_id in test
  results[test_user_id] = []
  if collab.has_key?(test_user_id)
    potential_repos = collab[test_user_id]
  
    # normalise by repo popularity
    for repo_id in potential_repos.keys
      potential_repos[repo_id] = potential_repos[repo_id].to_f / repo_followers[repo_id].length.to_f
    end

    # rank by repo score
    ranked_potential_repos = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }

    # recommend top ten
    (0..Util.min(9, ranked_potential_repos.length)).each { |i| results[test_user_id] << ranked_potential_repos[i] }
  end
end

InOut.output_results(results)