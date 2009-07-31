require 'in_out'
require 'util'

data = InOut.read_data()
repo_followers = Util.rotate_hash(data)
#repos = read_repos()
test = InOut.read_test()

users_repos = {}
counter = 0
for test_user_id in test
  users_repos[test_user_id] = []

  potential_repos = {}
  if data.has_key?(test_user_id)
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
  
    ranked_potential_repos = potential_repos.keys().sort { |x,y| potential_repos[y] <=> potential_repos[x] }
    (0..Util.min(9, ranked_potential_repos.length)).each { |i| users_repos[test_user_id] << ranked_potential_repos[i] }
  end
  
  print counter.to_s + "\n"
  counter += 1
end

InOut.output_results(users_repos)