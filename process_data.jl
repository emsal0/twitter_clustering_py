data_path = ARGS[1] # ARGS[1] must be a directory

usernames = [];
validFiles = [];

function getUsername(filename)
    m = match(r"^(.*)\.txt$", filename)
    (s,) = size(m.captures)
    if s < 1
        return ""
    else
        return String(m.captures[1])
    end
end

## TODO -- some kind of tree so i can find nearest neighbours

function densityClustering(dataPoints)
    clusters = []
    visited = Set()
    for point in dataPoints

    end
end

for (_, _, fs) in walkdir(data_path)
    usernames = filter(u -> u != "", map(getUsername, fs))
    validFiles = map(u -> joinpath(data_path, "$(u).txt"), usernames);
end

followed = Dict()

mutable struct FollowedAccount
    numFollowing::Int
    following::Array{String}
end

for (n, file) in enumerate(validFiles)
    strm = open(file, "r")
    followedAccs = readlines(strm)
    for acc in followedAccs
        if haskey(followed, acc)
            followed[acc].numFollowing += 1
            push!(followed[acc].following, usernames[n])
        else
            followed[acc] = FollowedAccount(1, [usernames[n]])
        end
    end
    close(strm)
end

THRESHOLD = 15

followingToCheck = []

for (accname, accdata) in followed
    if accdata.numFollowing >= THRESHOLD
        push!(followingToCheck, accname)
    end
end

t_noneinthr = []
for username in usernames
    inAcc = map(acc -> in(username, followed[acc].following), followingToCheck)
    if !any(inAcc)
        push!(t_noneinthr, username)
    end
end

usernamesFiltered = filter(name -> !in(name, t_noneinthr), usernames)

dataPoints = []

(dim,) = size(followingToCheck)

for username in usernamesFiltered
    vec = zeros(dim,1)

    for (index, followedAcc) in enumerate(followingToCheck)
        if in(username, followed[followedAcc].following)
            vec[index] = 1
        end
    end

    push!(dataPoints, vec)
end

println(dataPoints[1])
println(size(dataPoints))
println(dim)
