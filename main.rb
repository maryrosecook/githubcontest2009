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
  followed_repos = {}
  
  if data.has_key?(test_user_id)
    for followed_repo_id in data[test_user_id]
      for follower_id in repo_followers[followed_repo_id]
        followed_repos[followed_repo_id] = 0 if !followed_repos.has_key?(followed_repo_id)
        followed_repos[followed_repo_id] += 1
      end
    end
  
    ranked_followed_repos = followed_repos.keys().sort { |x,y| followed_repos[y] <=> followed_repos[x] }
  
    i = 0
    for repo_id in ranked_followed_repos
      users_repos[test_user_id] << repo_id
      break if i >= 9
      i += 1
    end
  end
  
  print counter.to_s + "\n"
  counter += 1
end

InOut.output_results(users_repos)