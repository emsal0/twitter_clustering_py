using TSne

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

function tsne_reduce(dataPoints)
    Y = tsne(dataPoints, 2, 0, 1000, 15.0)

    return Y
end

function cluster(dataPoints)
    n = size(dataPoints, 1)

    MINPTS = 5
    RADIUS = sqrt(n * 3 / 10)

    y = zeros(n)

    currentClusterNum = 1


    for i in 1:n
        distances=[]
        for j in 1:n
            if i !== j
                push!(distances, norm(dataPoints[j, :] - dataPoints[i, :]))
            end
        end

        if sort(distances)[MINPTS] <= RADIUS
            expandCluster(dataPoints, i)
        end
    end
end

function expandCluster(dataPoints, idx)

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

(dim,) = size(followingToCheck)

(n,) = size(usernamesFiltered)
dataPoints = zeros(n,dim)

for (usernameIdx, username) in enumerate(usernamesFiltered)

    for (followedIdx, followedAcc) in enumerate(followingToCheck)
        if in(username, followed[followedAcc].following)
            dataPoints[usernameIdx, followedIdx] = 1
        end
    end
end

# println(dataPoints[1])
# println(size(dataPoints))
# println(dim)

function rescale(A, dim::Integer=1)
    res = A .- mean(A, dim)
    res ./= map!(x -> x > 0.0 ? x : 1.0, std(A, dim))
    res
end

reshapedData = convert(Matrix{Float64}, dataPoints)'
X = rescale(reshapedData, 1)
reduced = tsne_reduce(X)

using Gadfly
p = plot(x=reduced[:,1], y=reduced[:,2])
draw(PDF("output.pdf", 6inch, 4inch), p)
